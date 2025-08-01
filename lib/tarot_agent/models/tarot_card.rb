# frozen_string_literal: true

require 'active_record'

module TarotAgent
  module Models
    # Represents a single tarot card with all its meanings and attributes
    class TarotCard < ActiveRecord::Base
      # Validations
      validates :name, presence: true, uniqueness: true
      validates :arcana, presence: true, inclusion: { in: %w[major minor] }
      validates :suit, inclusion: { in: %w[cups wands swords pentacles], allow_nil: true }
      validates :number, numericality: { only_integer: true, allow_nil: true }
      
      # Scopes for querying cards
      scope :major_arcana, -> { where(arcana: 'major') }
      scope :minor_arcana, -> { where(arcana: 'minor') }
      scope :by_suit, ->(suit) { where(suit: suit) }
      scope :by_element, ->(element) { where(element: element) }
      
      # Check if card is major arcana
      def major?
        arcana == 'major'
      end
      
      # Check if card is minor arcana
      def minor?
        arcana == 'minor'
      end
      
      # Get full card title with suit if applicable
      def full_name
        if minor? && suit
          "#{name} of #{suit.capitalize}"
        else
          name
        end
      end
      
      # Get keywords as array
      def keywords_array
        keywords&.split(',')&.map(&:strip) || []
      end
      
      # Get a random meaning (upright or reversed)
      def random_meaning
        [upright_meaning, reversed_meaning].sample
      end
      
      # Draw a random card
      def self.draw_random
        order('RANDOM()').first
      end
      
      # Draw multiple random cards without replacement
      def self.draw_cards(count)
        order('RANDOM()').limit(count)
      end
      
      # Format card for display
      def to_display
        {
          name: full_name,
          arcana: arcana,
          keywords: keywords_array,
          element: element,
          astrological_sign: astrological_sign
        }
      end
    end
  end
end