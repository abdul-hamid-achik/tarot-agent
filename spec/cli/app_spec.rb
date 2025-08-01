# frozen_string_literal: true

require 'spec_helper'
require 'tarot_agent/cli/app'

RSpec.describe TarotAgent::CLI::App do
  let(:cli) { described_class.new }
  let(:prompt) { instance_double(TTY::Prompt) }
  let(:tarot_service) { instance_double(TarotAgent::Services::TarotService) }
  let(:test_reading) do
    create_test_reading(
      question: 'Test question?',
      claude_interpretation: 'Test interpretation',
      claude_advice: 'Test advice'
    )
  end

  before do
    # Mock TTY::Prompt
    allow(TTY::Prompt).to receive(:new).and_return(prompt)
    
    # Mock TarotService
    allow(TarotAgent::Services::TarotService).to receive(:new).and_return(tarot_service)
    
    # Mock database connection
    allow(TarotAgent::Database).to receive(:connect!)
    
    # Suppress output during tests
    allow($stdout).to receive(:puts)
    allow($stdout).to receive(:print)
    
    # Mock system calls for clear screen
    allow(cli).to receive(:system).and_return(true)
  end

  describe '#reading' do
    before do
      # Mock user inputs
      allow(prompt).to receive(:ask).with('What is your name?', default: 'Seeker')
                                     .and_return('Test User')
      allow(prompt).to receive(:ask).with('What would you like to know about?')
                                     .and_return('What does the future hold?')
      allow(prompt).to receive(:select).with('Choose your spread:')
                                       .and_return(:single)
      allow(prompt).to receive(:select).with('What would you like to do?')
                                       .and_return(:exit)
      
      # Mock service response
      allow(tarot_service).to receive(:single_card_reading)
                          .and_return(test_reading)
      
      # Mock spinner
      spinner = instance_double(TTY::Spinner)
      allow(TTY::Spinner).to receive(:new).and_return(spinner)
      allow(spinner).to receive(:auto_spin)
      allow(spinner).to receive(:success)
    end

    it 'prompts for user name' do
      expect(prompt).to receive(:ask).with('What is your name?', default: 'Seeker')
      cli.reading
    end

    it 'prompts for question with validation' do
      expect(prompt).to receive(:ask).with('What would you like to know about?') do |&block|
        # Test the validation block if provided
        'What does the future hold?'
      end
      cli.reading
    end

    it 'prompts for spread type' do
      expect(prompt).to receive(:select).with('Choose your spread:')
      cli.reading
    end

    it 'calls appropriate service method based on spread choice' do
      allow(prompt).to receive(:select).with('Choose your spread:').and_return(:three_card)
      allow(tarot_service).to receive(:three_card_reading).and_return(test_reading)
      
      expect(tarot_service).to receive(:three_card_reading)
                          .with('What does the future hold?', 'Test User')
      cli.reading
    end

    it 'displays the reading' do
      expect(cli).to receive(:display_reading).with(test_reading)
      cli.reading
    end

    it 'handles follow-up options' do
      expect(cli).to receive(:handle_followup).with(test_reading)
      cli.reading
    end
  end

  describe '#history' do
    let(:readings) { [test_reading] }

    before do
      allow(tarot_service).to receive(:recent_readings).and_return(readings)
      allow(prompt).to receive(:yes?).and_return(false)
    end

    it 'fetches recent readings' do
      expect(tarot_service).to receive(:recent_readings).with(10)
      cli.history
    end

    it 'displays reading summaries' do
      expect(cli).to receive(:display_reading_summary).with(test_reading)
      cli.history
    end

    context 'when user wants to view full reading' do
      before do
        allow(prompt).to receive(:yes?).with('Would you like to view a full reading?')
                                       .and_return(true)
        allow(prompt).to receive(:ask).with('Enter reading ID:', convert: :int)
                                      .and_return(test_reading.id)
        allow(tarot_service).to receive(:get_reading).and_return(test_reading)
        allow(prompt).to receive(:select).and_return(:exit)
      end

      it 'prompts for reading ID' do
        expect(prompt).to receive(:ask).with('Enter reading ID:', convert: :int)
        cli.history
      end

      it 'displays the full reading' do
        expect(cli).to receive(:display_reading).with(test_reading)
        cli.history
      end
    end

    context 'when no readings exist' do
      before do
        allow(tarot_service).to receive(:recent_readings).and_return([])
      end

      it 'displays appropriate message' do
        expect($stdout).to receive(:puts)
          .with(/No readings found/)
        cli.history
      end
    end
  end

  describe '#cards' do
    let(:test_card) { create_test_card(name: 'Test Card') }

    before do
      allow(prompt).to receive(:select).with('What would you like to explore?')
                                       .and_return(:major)
      allow(prompt).to receive(:yes?).and_return(false)
      allow(TarotAgent::Models::TarotCard).to receive(:major_arcana)
                                           .and_return([test_card])
    end

    it 'displays menu options' do
      expect(prompt).to receive(:select).with('What would you like to explore?')
      cli.cards
    end

    context 'when exploring major arcana' do
      it 'displays major arcana cards' do
        expect(cli).to receive(:display_cards)
          .with(TarotAgent::Models::TarotCard.major_arcana)
        cli.cards
      end
    end

    context 'when exploring minor arcana' do
      before do
        allow(prompt).to receive(:select).with('What would you like to explore?')
                                         .and_return(:minor)
        allow(prompt).to receive(:select).with('Choose a suit:')
                                         .and_return('cups')
        allow(TarotAgent::Models::TarotCard).to receive(:by_suit)
                                             .and_return([test_card])
      end

      it 'prompts for suit selection' do
        expect(prompt).to receive(:select).with('Choose a suit:')
        cli.cards
      end

      it 'displays cards of selected suit' do
        expect(cli).to receive(:display_cards)
        cli.cards
      end
    end

    context 'when searching by keyword' do
      before do
        allow(prompt).to receive(:select).with('What would you like to explore?')
                                         .and_return(:search)
        allow(prompt).to receive(:ask).with('Enter keyword to search:')
                                      .and_return('love')
        allow(TarotAgent::Models::TarotCard).to receive(:where)
                                             .and_return([test_card])
      end

      it 'prompts for keyword' do
        expect(prompt).to receive(:ask).with('Enter keyword to search:')
        cli.cards
      end

      it 'searches cards by keyword' do
        expect(TarotAgent::Models::TarotCard).to receive(:where)
          .with('keywords LIKE ?', '%love%')
        cli.cards
      end
    end

    context 'when viewing random card' do
      before do
        allow(prompt).to receive(:select).with('What would you like to explore?')
                                         .and_return(:random)
        allow(TarotAgent::Models::TarotCard).to receive(:draw_random)
                                             .and_return(test_card)
      end

      it 'draws a random card' do
        expect(TarotAgent::Models::TarotCard).to receive(:draw_random)
        cli.cards
      end

      it 'displays card details' do
        expect(cli).to receive(:display_card_detail).with(test_card)
        cli.cards
      end
    end
  end

  describe '#version' do
    it 'displays version information' do
      expect($stdout).to receive(:puts).with(/Tarot Agent v1.0.0/)
      expect($stdout).to receive(:puts).with(/Claude 3.5/)
      cli.version
    end
  end

  describe 'private helper methods' do
    describe '#word_wrap' do
      it 'wraps text at specified width' do
        long_text = 'a' * 100
        wrapped = cli.send(:word_wrap, long_text, 20)
        lines = wrapped.split("\n")
        
        lines.each do |line|
          expect(line.length).to be <= 20
        end
      end

      it 'handles nil text' do
        result = cli.send(:word_wrap, nil)
        expect(result).to eq('')
      end

      it 'preserves existing line breaks' do
        text = "Line 1\nLine 2\nLine 3"
        result = cli.send(:word_wrap, text)
        expect(result.split("\n").size).to be >= 3
      end
    end

    describe '#handle_followup' do
      before do
        allow(prompt).to receive(:select).with('What would you like to do?')
                                         .and_return(:exit)
      end

      context 'when user asks follow-up question' do
        before do
          allow(prompt).to receive(:select).and_return(:followup, :exit)
          allow(prompt).to receive(:ask).with('Your follow-up question:')
                                        .and_return('Tell me more')
          allow(tarot_service).to receive(:ask_followup).and_return('More details')
          
          # Mock spinner
          spinner = instance_double(TTY::Spinner)
          allow(TTY::Spinner).to receive(:new).and_return(spinner)
          allow(spinner).to receive(:auto_spin)
          allow(spinner).to receive(:success)
        end

        it 'prompts for follow-up question' do
          expect(prompt).to receive(:ask).with('Your follow-up question:')
          cli.send(:handle_followup, test_reading)
        end

        it 'calls tarot service with follow-up' do
          expect(tarot_service).to receive(:ask_followup)
            .with(test_reading.id, 'Tell me more')
          cli.send(:handle_followup, test_reading)
        end
      end

      context 'when user chooses to exit' do
        it 'displays farewell message' do
          expect($stdout).to receive(:puts).with(/Thank you for using Tarot Agent/)
          cli.send(:handle_followup, test_reading)
        end
      end
    end
  end
end