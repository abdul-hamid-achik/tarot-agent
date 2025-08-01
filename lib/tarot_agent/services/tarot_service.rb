# frozen_string_literal: true

require_relative '../models/tarot_card'
require_relative '../models/reading'
require_relative 'claude_service'

module TarotAgent
  module Services
    # Service for performing tarot readings
    class TarotService
      attr_reader :claude_service
      
      # Initialize the tarot service
      def initialize
        @claude_service = ClaudeService.new
      end
      
      # Perform a single card reading
      def single_card_reading(question, querent_name = nil)
        # Draw one card
        card = TarotAgent::Models::TarotCard.draw_random
        reversed = [true, false].sample
        
        # Create reading record
        reading = TarotAgent::Models::Reading.create!(
          question: question,
          spread_type: 'single',
          querent_name: querent_name,
          performed_at: Time.current
        )
        
        # Add card to reading
        reading.add_card(card)
        reading.save!
        
        # Get interpretation from Claude
        cards_data = [{
          card: card,
          position: 'Present Situation',
          reversed: reversed
        }]
        
        interpretation = claude_service.interpret_reading(cards_data, question, 'single')
        advice = claude_service.generate_advice(cards_data, question, interpretation)
        
        # Update reading with interpretations
        reading.update!(
          claude_interpretation: interpretation,
          claude_advice: advice
        )
        
        reading
      end
      
      # Perform a three-card reading (Past, Present, Future)
      def three_card_reading(question, querent_name = nil)
        # Draw three cards
        cards = TarotAgent::Models::TarotCard.draw_cards(3).to_a
        positions = ['Past', 'Present', 'Future']
        
        # Create reading record
        reading = TarotAgent::Models::Reading.create!(
          question: question,
          spread_type: 'three_card',
          querent_name: querent_name,
          performed_at: Time.current
        )
        
        # Add cards to reading with positions
        cards_data = []
        cards.each_with_index do |card, index|
          reversed = [true, false].sample
          reading.add_card(card, positions[index])
          cards_data << {
            card: card,
            position: positions[index],
            reversed: reversed
          }
        end
        reading.save!
        
        # Get interpretation from Claude
        interpretation = claude_service.interpret_reading(cards_data, question, 'three_card')
        advice = claude_service.generate_advice(cards_data, question, interpretation)
        
        # Update reading with interpretations
        reading.update!(
          claude_interpretation: interpretation,
          claude_advice: advice
        )
        
        reading
      end
      
      # Perform a relationship spread
      def relationship_reading(question, querent_name = nil)
        # Draw five cards for relationship spread
        cards = TarotAgent::Models::TarotCard.draw_cards(5).to_a
        positions = [
          'You',
          'Partner',
          'Connection',
          'Challenge',
          'Outcome'
        ]
        
        # Create reading record
        reading = TarotAgent::Models::Reading.create!(
          question: question,
          spread_type: 'relationship',
          querent_name: querent_name,
          performed_at: Time.current
        )
        
        # Add cards to reading with positions
        cards_data = []
        cards.each_with_index do |card, index|
          reversed = [true, false].sample
          reading.add_card(card, positions[index])
          cards_data << {
            card: card,
            position: positions[index],
            reversed: reversed
          }
        end
        reading.save!
        
        # Get interpretation from Claude
        interpretation = claude_service.interpret_reading(cards_data, question, 'relationship')
        advice = claude_service.generate_advice(cards_data, question, interpretation)
        
        # Update reading with interpretations
        reading.update!(
          claude_interpretation: interpretation,
          claude_advice: advice
        )
        
        reading
      end
      
      # Get recent readings
      def recent_readings(limit = 5)
        TarotAgent::Models::Reading.recent.limit(limit)
      end
      
      # Get a specific reading by ID
      def get_reading(id)
        TarotAgent::Models::Reading.find(id)
      rescue ActiveRecord::RecordNotFound
        nil
      end
      
      # Ask a follow-up question about a reading
      def ask_followup(reading_id, question)
        reading = get_reading(reading_id)
        return nil unless reading
        
        claude_service.ask_followup(reading, question)
      end
    end
  end
end