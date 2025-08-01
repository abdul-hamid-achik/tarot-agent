# frozen_string_literal: true

require 'anthropic'
require 'json'

module TarotAgent
  module Services
    # Service for interacting with Claude API for tarot interpretations
    class ClaudeService
      attr_reader :client
      
      # Initialize the Claude service with API key
      def initialize(api_key = ENV['ANTHROPIC_API_KEY'])
        raise 'ANTHROPIC_API_KEY is required' unless api_key
        
        @client = Anthropic::Client.new(access_token: api_key)
      end
      
      # Generate a tarot reading interpretation
      def interpret_reading(cards, question, spread_type = 'three_card')
        prompt = build_interpretation_prompt(cards, question, spread_type)
        
        response = client.messages(
          parameters: {
            model: 'claude-3-5-sonnet-20241022', # Using Claude 3.5 Sonnet
            messages: [
              { role: 'user', content: prompt }
            ],
            max_tokens: 1500,
            temperature: 0.7
          }
        )
        
        # Extract the interpretation from the response
        extract_interpretation(response)
      rescue StandardError => e
        handle_api_error(e)
      end
      
      # Generate advice based on the reading
      def generate_advice(cards, question, interpretation)
        prompt = build_advice_prompt(cards, question, interpretation)
        
        response = client.messages(
          parameters: {
            model: 'claude-3-5-sonnet-20241022',
            messages: [
              { role: 'user', content: prompt }
            ],
            max_tokens: 800,
            temperature: 0.8
          }
        )
        
        extract_interpretation(response)
      rescue StandardError => e
        handle_api_error(e)
      end
      
      # Ask Claude a follow-up question about the reading
      def ask_followup(reading, followup_question)
        prompt = build_followup_prompt(reading, followup_question)
        
        response = client.messages(
          parameters: {
            model: 'claude-3-5-sonnet-20241022',
            messages: [
              { role: 'user', content: prompt }
            ],
            max_tokens: 1000,
            temperature: 0.7
          }
        )
        
        extract_interpretation(response)
      rescue StandardError => e
        handle_api_error(e)
      end
      
      private
      
      # Build the interpretation prompt
      def build_interpretation_prompt(cards, question, spread_type)
        cards_description = cards.map do |card|
          position = card[:position] || 'General'
          reversed = card[:reversed] ? ' (Reversed)' : ''
          
          "#{position}: #{card[:card].full_name}#{reversed}
          Keywords: #{card[:card].keywords}
          Upright Meaning: #{card[:card].upright_meaning}
          Reversed Meaning: #{card[:card].reversed_meaning}"
        end.join("\n\n")
        
        <<~PROMPT
          You are an experienced tarot reader providing insightful interpretations.
          
          Question asked: #{question}
          Spread type: #{spread_type}
          
          Cards drawn:
          #{cards_description}
          
          Please provide a comprehensive interpretation of this tarot reading that:
          1. Addresses the querent's question directly
          2. Explains how each card relates to the question and position
          3. Identifies connections and patterns between the cards
          4. Offers insights into the current situation and potential outcomes
          5. Maintains a compassionate and empowering tone
          
          Format your response in clear paragraphs, avoiding bullet points.
        PROMPT
      end
      
      # Build the advice prompt
      def build_advice_prompt(cards, question, interpretation)
        <<~PROMPT
          Based on this tarot reading interpretation:
          
          Question: #{question}
          
          Interpretation:
          #{interpretation}
          
          Please provide practical, actionable advice that:
          1. Helps the querent navigate their situation
          2. Suggests concrete steps they can take
          3. Highlights opportunities for growth
          4. Acknowledges potential challenges while remaining constructive
          5. Empowers the querent to make their own choices
          
          Keep the advice concise and focused on what the querent can control.
        PROMPT
      end
      
      # Build follow-up question prompt
      def build_followup_prompt(reading, followup_question)
        <<~PROMPT
          Previous tarot reading:
          Question: #{reading.question}
          Interpretation: #{reading.claude_interpretation}
          Advice: #{reading.claude_advice}
          
          Follow-up question: #{followup_question}
          
          Please provide a thoughtful response that:
          1. Directly addresses the follow-up question
          2. References the original reading where relevant
          3. Provides additional insights or clarification
          4. Maintains consistency with the original interpretation
        PROMPT
      end
      
      # Extract interpretation from API response
      def extract_interpretation(response)
        return nil unless response && response['content']
        
        # The response content is an array of content blocks
        content_blocks = response['content']
        return nil unless content_blocks.is_a?(Array) && !content_blocks.empty?
        
        # Extract text from the first content block
        first_block = content_blocks.first
        first_block['text'] if first_block && first_block['type'] == 'text'
      end
      
      # Handle API errors gracefully
      def handle_api_error(error)
        case error
        when Anthropic::Error
          puts "Claude API error: #{error.message}"
          nil
        else
          puts "Unexpected error: #{error.message}"
          nil
        end
      end
    end
  end
end