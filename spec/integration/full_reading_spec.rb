# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Full Reading Integration', type: :integration do
  let(:service) { TarotAgent::Services::TarotService.new }
  let(:mock_claude) { instance_double(TarotAgent::Services::ClaudeService) }
  
  before do
    # Mock Claude responses for integration tests
    allow(TarotAgent::Services::ClaudeService).to receive(:new).and_return(mock_claude)
    allow(mock_claude).to receive(:interpret_reading) do |cards, question, _|
      "Interpretation for: #{question}. You drew #{cards.size} card(s)."
    end
    allow(mock_claude).to receive(:generate_advice) do |_, question, _|
      "Advice for: #{question}"
    end
    
    # Ensure database has cards
    if TarotAgent::Models::TarotCard.count < 5
      5.times { |i| create_test_card(name: "Integration Card #{i}") }
    end
  end

  describe 'Complete reading workflow' do
    it 'performs a single card reading end-to-end' do
      question = 'What should I focus on today?'
      
      # Perform reading
      reading = service.single_card_reading(question, 'Test User')
      
      # Verify reading was created
      expect(reading).to be_persisted
      expect(reading.question).to eq(question)
      expect(reading.querent_name).to eq('Test User')
      
      # Verify card was drawn
      expect(reading.drawn_cards.size).to eq(1)
      card_data = reading.drawn_cards.first
      expect(card_data).to have_key(:card_id)
      expect(card_data).to have_key(:position)
      expect(card_data).to have_key(:reversed)
      
      # Verify interpretation was generated
      expect(reading.claude_interpretation).to include('Interpretation for')
      expect(reading.claude_interpretation).to include(question)
      
      # Verify advice was generated
      expect(reading.claude_advice).to include('Advice for')
      
      # Verify reading can be retrieved
      retrieved = TarotAgent::Models::Reading.find(reading.id)
      expect(retrieved.question).to eq(question)
    end

    it 'performs a three-card reading with correct positions' do
      question = 'How will my situation evolve?'
      
      reading = service.three_card_reading(question)
      
      # Verify three cards with correct positions
      expect(reading.drawn_cards.size).to eq(3)
      positions = reading.drawn_cards.map { |c| c[:position] }
      expect(positions).to eq(['Past', 'Present', 'Future'])
      
      # Verify each card is different
      card_ids = reading.drawn_cards.map { |c| c[:card_id] }
      expect(card_ids.uniq.size).to eq(3)
    end

    it 'performs a relationship reading with five cards' do
      question = 'How is my relationship progressing?'
      
      reading = service.relationship_reading(question)
      
      # Verify five cards with relationship positions
      expect(reading.drawn_cards.size).to eq(5)
      positions = reading.drawn_cards.map { |c| c[:position] }
      expected = ['You', 'Partner', 'Connection', 'Challenge', 'Outcome']
      expect(positions).to eq(expected)
    end
  end

  describe 'Reading history and retrieval' do
    before do
      # Create test readings
      3.times do |i|
        service.single_card_reading("Question #{i}", "User #{i}")
      end
    end

    it 'retrieves recent readings in correct order' do
      readings = service.recent_readings(5)
      
      # Should be ordered by most recent first
      timestamps = readings.map(&:performed_at)
      expect(timestamps).to eq(timestamps.sort.reverse)
      
      # Should contain our test readings
      questions = readings.map(&:question)
      expect(questions).to include('Question 2')
    end

    it 'retrieves specific reading by ID' do
      # Create a specific reading
      reading = service.single_card_reading('Find me later')
      
      # Retrieve it
      found = service.get_reading(reading.id)
      expect(found).not_to be_nil
      expect(found.question).to eq('Find me later')
    end
  end

  describe 'Follow-up questions' do
    let(:reading) do
      service.single_card_reading('Initial question')
    end

    before do
      allow(mock_claude).to receive(:ask_followup) do |r, q|
        "Follow-up response to: #{q}"
      end
    end

    it 'handles follow-up questions on existing readings' do
      followup = 'Can you tell me more about the card?'
      
      response = service.ask_followup(reading.id, followup)
      
      expect(response).to include('Follow-up response to')
      expect(response).to include(followup)
    end

    it 'returns nil for non-existent reading' do
      response = service.ask_followup(999999, 'Question')
      expect(response).to be_nil
    end
  end

  describe 'Database persistence' do
    it 'persists readings across service instances' do
      # Create reading with first service instance
      service1 = TarotAgent::Services::TarotService.new
      reading = service1.single_card_reading('Persistent question')
      reading_id = reading.id
      
      # Retrieve with second service instance
      service2 = TarotAgent::Services::TarotService.new
      found = service2.get_reading(reading_id)
      
      expect(found).not_to be_nil
      expect(found.question).to eq('Persistent question')
    end

    it 'maintains card associations' do
      reading = service.three_card_reading('Test associations')
      
      # Reload from database
      reloaded = TarotAgent::Models::Reading.find(reading.id)
      
      # Verify cards are still associated
      expect(reloaded.tarot_cards.size).to eq(3)
      expect(reloaded.drawn_cards.size).to eq(3)
    end
  end

  describe 'Error handling' do
    context 'when Claude service fails' do
      before do
        allow(mock_claude).to receive(:interpret_reading).and_return(nil)
        allow(mock_claude).to receive(:generate_advice).and_return(nil)
      end

      it 'still creates reading even if interpretation fails' do
        reading = service.single_card_reading('Test question')
        
        expect(reading).to be_persisted
        expect(reading.drawn_cards).not_to be_empty
        expect(reading.claude_interpretation).to be_nil
        expect(reading.claude_advice).to be_nil
      end
    end

    context 'when insufficient cards in database' do
      before do
        TarotAgent::Models::TarotCard.destroy_all
        create_test_card(name: 'Only Card')
      end

      it 'handles single card reading with one card' do
        reading = service.single_card_reading('One card test')
        expect(reading.drawn_cards.size).to eq(1)
      end

      it 'handles three-card reading with insufficient cards' do
        reading = service.three_card_reading('Not enough cards')
        # Should only draw what's available
        expect(reading.drawn_cards.size).to eq(1)
      end
    end
  end

  describe 'Card randomization and reversal' do
    it 'randomly assigns reversed status' do
      # Perform multiple readings to test randomization
      reversed_statuses = []
      
      10.times do
        reading = service.single_card_reading('Test reversal')
        reversed_statuses << reading.drawn_cards.first[:reversed]
      end
      
      # Should have both true and false values
      expect(reversed_statuses).to include(true)
      expect(reversed_statuses).to include(false)
    end

    it 'draws different cards across readings' do
      # Ensure we have enough cards
      5.times { |i| create_test_card(name: "Random Test #{i}") }
      
      card_names = []
      5.times do
        reading = service.single_card_reading('Test variety')
        card = reading.tarot_cards.first
        card_names << card.name
      end
      
      # Should have variety in cards drawn
      expect(card_names.uniq.size).to be >= 2
    end
  end
end