# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TarotAgent::Services::ClaudeService do
  let(:api_key) { 'test-api-key' }
  let(:service) { described_class.new(api_key) }
  let(:mock_client) { instance_double(Anthropic::Client) }
  
  before do
    allow(Anthropic::Client).to receive(:new).and_return(mock_client)
  end

  describe '#initialize' do
    it 'creates an Anthropic client with the provided API key' do
      expect(Anthropic::Client).to receive(:new).with(access_token: api_key)
      described_class.new(api_key)
    end

    it 'raises error when API key is not provided' do
      expect { described_class.new(nil) }.to raise_error('ANTHROPIC_API_KEY is required')
    end

    it 'uses environment variable when no key provided' do
      ENV['ANTHROPIC_API_KEY'] = 'env-key'
      expect(Anthropic::Client).to receive(:new).with(access_token: 'env-key')
      described_class.new
    end
  end

  describe '#interpret_reading' do
    let(:card) { create_test_card(name: 'The Fool', keywords: 'new beginnings, innocence') }
    let(:cards_data) do
      [{
        card: card,
        position: 'Present',
        reversed: false
      }]
    end
    let(:question) { 'What should I focus on today?' }
    
    context 'with successful API response' do
      let(:api_response) { mock_claude_response('This is a test interpretation') }
      
      before do
        allow(mock_client).to receive(:messages).and_return(api_response)
      end

      it 'sends correct parameters to Claude API' do
        expect(mock_client).to receive(:messages).with(
          parameters: hash_including(
            model: 'claude-3-5-sonnet-20241022',
            max_tokens: 1500,
            temperature: 0.7
          )
        )
        
        service.interpret_reading(cards_data, question)
      end

      it 'includes card information in the prompt' do
        expect(mock_client).to receive(:messages) do |args|
          prompt = args[:parameters][:messages].first[:content]
          expect(prompt).to include('The Fool')
          expect(prompt).to include('new beginnings, innocence')
          expect(prompt).to include('Present')
          api_response
        end
        
        service.interpret_reading(cards_data, question)
      end

      it 'returns the interpretation text' do
        result = service.interpret_reading(cards_data, question)
        expect(result).to eq('This is a test interpretation')
      end
    end

    context 'with API error' do
      before do
        allow(mock_client).to receive(:messages).and_raise(Anthropic::Error.new('API Error'))
      end

      it 'handles API errors gracefully' do
        expect { service.interpret_reading(cards_data, question) }.not_to raise_error
      end

      it 'returns nil on error' do
        result = service.interpret_reading(cards_data, question)
        expect(result).to be_nil
      end

      it 'logs the error' do
        expect { service.interpret_reading(cards_data, question) }
          .to output(/Claude API error: API Error/).to_stdout
      end
    end
  end

  describe '#generate_advice' do
    let(:card) { create_test_card }
    let(:cards_data) { [{ card: card, position: 'Present', reversed: false }] }
    let(:question) { 'How can I improve my situation?' }
    let(:interpretation) { 'You are at a crossroads...' }
    
    context 'with successful API response' do
      let(:api_response) { mock_claude_response('Here is your advice...') }
      
      before do
        allow(mock_client).to receive(:messages).and_return(api_response)
      end

      it 'includes interpretation in the prompt' do
        expect(mock_client).to receive(:messages) do |args|
          prompt = args[:parameters][:messages].first[:content]
          expect(prompt).to include('You are at a crossroads')
          expect(prompt).to include(question)
          api_response
        end
        
        service.generate_advice(cards_data, question, interpretation)
      end

      it 'uses appropriate temperature for advice' do
        expect(mock_client).to receive(:messages).with(
          parameters: hash_including(
            temperature: 0.8,
            max_tokens: 800
          )
        )
        
        service.generate_advice(cards_data, question, interpretation)
      end

      it 'returns the advice text' do
        result = service.generate_advice(cards_data, question, interpretation)
        expect(result).to eq('Here is your advice...')
      end
    end
  end

  describe '#ask_followup' do
    let(:reading) do
      create_test_reading(
        question: 'Original question?',
        claude_interpretation: 'Original interpretation',
        claude_advice: 'Original advice'
      )
    end
    let(:followup_question) { 'Can you elaborate on the first card?' }
    
    context 'with successful API response' do
      let(:api_response) { mock_claude_response('Follow-up response') }
      
      before do
        allow(mock_client).to receive(:messages).and_return(api_response)
      end

      it 'includes reading context in the prompt' do
        expect(mock_client).to receive(:messages) do |args|
          prompt = args[:parameters][:messages].first[:content]
          expect(prompt).to include('Original question?')
          expect(prompt).to include('Original interpretation')
          expect(prompt).to include('Original advice')
          expect(prompt).to include(followup_question)
          api_response
        end
        
        service.ask_followup(reading, followup_question)
      end

      it 'returns the follow-up response' do
        result = service.ask_followup(reading, followup_question)
        expect(result).to eq('Follow-up response')
      end
    end
  end

  describe 'private methods' do
    describe '#extract_interpretation' do
      it 'extracts text from valid response' do
        response = mock_claude_response('Extracted text')
        result = service.send(:extract_interpretation, response)
        expect(result).to eq('Extracted text')
      end

      it 'handles nil response' do
        result = service.send(:extract_interpretation, nil)
        expect(result).to be_nil
      end

      it 'handles response without content' do
        result = service.send(:extract_interpretation, {})
        expect(result).to be_nil
      end

      it 'handles non-text content blocks' do
        response = {
          'content' => [{ 'type' => 'image', 'data' => 'base64...' }]
        }
        result = service.send(:extract_interpretation, response)
        expect(result).to be_nil
      end
    end

    describe '#handle_api_error' do
      it 'handles Anthropic errors' do
        error = Anthropic::Error.new('Test error')
        expect { service.send(:handle_api_error, error) }
          .to output(/Claude API error: Test error/).to_stdout
      end

      it 'handles unexpected errors' do
        error = StandardError.new('Unexpected')
        expect { service.send(:handle_api_error, error) }
          .to output(/Unexpected error: Unexpected/).to_stdout
      end

      it 'returns nil for any error' do
        error = StandardError.new('Any error')
        result = service.send(:handle_api_error, error)
        expect(result).to be_nil
      end
    end
  end
end