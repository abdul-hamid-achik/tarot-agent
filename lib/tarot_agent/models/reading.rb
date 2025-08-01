# frozen_string_literal: true

require 'active_record'
require 'json'

module TarotAgent
  module Models
    # Represents a tarot reading session with AI interpretation
    class Reading < ActiveRecord::Base
      # Validations
      validates :question, presence: true
      validates :spread_type, inclusion: { 
        in: %w[single three_card celtic_cross past_present_future relationship], 
        allow_nil: true 
      }
      
      # Callbacks
      before_create :set_performed_at
      
      # Scopes
      scope :recent, -> { order(performed_at: :desc) }
      scope :by_spread, ->(type) { where(spread_type: type) }
      scope :today, -> { where('performed_at >= ?', Date.current.beginning_of_day) }
      
      # Parse cards_drawn JSON
      def drawn_cards
        return [] unless cards_drawn
        JSON.parse(cards_drawn, symbolize_names: true)
      rescue JSON::ParserError
        []
      end
      
      # Set cards drawn as JSON
      def drawn_cards=(cards)
        self.cards_drawn = cards.to_json
      end
      
      # Get actual TarotCard objects
      def tarot_cards
        card_ids = drawn_cards.map { |c| c[:card_id] }
        TarotCard.where(id: card_ids)
      end
      
      # Add a card to the reading
      def add_card(card, position = nil)
        cards = drawn_cards
        cards << { 
          card_id: card.id, 
          position: position || cards.length,
          reversed: [true, false].sample # Randomly determine if reversed
        }
        self.drawn_cards = cards
      end
      
      # Check if reading has interpretation
      def interpreted?
        claude_interpretation.present?
      end
      
      # Get spread description
      def spread_description
        case spread_type
        when 'single'
          'Single Card Draw'
        when 'three_card'
          'Three Card Spread'
        when 'celtic_cross'
          'Celtic Cross Spread'
        when 'past_present_future'
          'Past, Present, Future'
        when 'relationship'
          'Relationship Spread'
        else
          'Custom Spread'
        end
      end
      
      # Format reading for display
      def to_display
        {
          id: id,
          question: question,
          spread: spread_description,
          cards: tarot_cards.map(&:full_name),
          interpretation: claude_interpretation,
          advice: claude_advice,
          performed_at: performed_at&.strftime('%B %d, %Y at %I:%M %p')
        }
      end
      
      private
      
      # Set performed_at timestamp
      def set_performed_at
        self.performed_at ||= Time.current
      end
    end
  end
end