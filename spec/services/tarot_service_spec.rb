# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TarotAgent::Services::TarotService do
  let(:service) { described_class.new }
  let(:mock_claude_service) { instance_double(TarotAgent::Services::ClaudeService) }
  
  before do
    allow(TarotAgent::Services::ClaudeService).to receive(:new).and_return(mock_claude_service)
    
    # Default mock responses
    allow(mock_claude_service).to receive(:interpret_reading).and_return('Test interpretation')
    allow(mock_claude_service).to receive(:generate_advice).and_return('Test advice')
    allow(mock_claude_service).to receive(:ask_followup).and_return('Test followup')
    
    # Ensure we have cards in the database
    create_test_card(name: 'Test Card 1')
    create_test_card(name: 'Test Card 2')
    create_test_card(name: 'Test Card 3')
    create_test_card(name: 'Test Card 4')
    create_test_card(name: 'Test Card 5')
  end

  describe '#initialize' do
    it 'creates a Claude service instance' do
      expect(TarotAgent::Services::ClaudeService).to receive(:new)
      described_class.new
    end
  end

  describe '#single_card_reading' do
    let(:question) { 'What should I focus on today?' }
    let(:querent_name) { 'Alice' }
    
    it 'creates a reading with single spread type' do
      reading = service.single_card_reading(question, querent_name)
      
      expect(reading).to be_persisted
      expect(reading.question).to eq(question)
      expect(reading.spread_type).to eq('single')
      expect(reading.querent_name).to eq(querent_name)
    end

    it 'draws exactly one card' do
      reading = service.single_card_reading(question)
      
      expect(reading.drawn_cards.size).to eq(1)
      expect(reading.tarot_cards.size).to eq(1)
    end

    it 'calls Claude service for interpretation' do
      expect(mock_claude_service).to receive(:interpret_reading) do |cards_data, q, spread|
        expect(cards_data.size).to eq(1)
        expect(cards_data.first[:position]).to eq('Present Situation')
        expect(q).to eq(question)
        expect(spread).to eq('single')
        'Test interpretation'
      end
      
      service.single_card_reading(question)
    end

    it 'calls Claude service for advice' do
      expect(mock_claude_service).to receive(:generate_advice) do |cards_data, q, interpretation|
        expect(cards_data.size).to eq(1)
        expect(q).to eq(question)
        expect(interpretation).to eq('Test interpretation')
        'Test advice'
      end
      
      service.single_card_reading(question)
    end

    it 'saves interpretation and advice to reading' do
      reading = service.single_card_reading(question)
      
      expect(reading.claude_interpretation).to eq('Test interpretation')
      expect(reading.claude_advice).to eq('Test advice')
    end

    it 'handles nil querent_name' do
      reading = service.single_card_reading(question, nil)
      expect(reading.querent_name).to be_nil
    end
  end

  describe '#three_card_reading' do
    let(:question) { 'How will my project evolve?' }
    let(:querent_name) { 'Bob' }
    
    it 'creates a reading with three_card spread type' do
      reading = service.three_card_reading(question, querent_name)
      
      expect(reading).to be_persisted
      expect(reading.spread_type).to eq('three_card')
    end

    it 'draws exactly three cards' do
      reading = service.three_card_reading(question)
      
      expect(reading.drawn_cards.size).to eq(3)
      expect(reading.tarot_cards.size).to eq(3)
    end

    it 'assigns correct positions to cards' do
      reading = service.three_card_reading(question)
      positions = reading.drawn_cards.map { |c| c[:position] }
      
      expect(positions).to eq(['Past', 'Present', 'Future'])
    end

    it 'calls Claude service with three cards' do
      expect(mock_claude_service).to receive(:interpret_reading) do |cards_data, _, spread|
        expect(cards_data.size).to eq(3)
        expect(cards_data.map { |c| c[:position] }).to eq(['Past', 'Present', 'Future'])
        expect(spread).to eq('three_card')
        'Test interpretation'
      end
      
      service.three_card_reading(question)
    end

    it 'saves interpretation and advice' do
      reading = service.three_card_reading(question)
      
      expect(reading.claude_interpretation).to eq('Test interpretation')
      expect(reading.claude_advice).to eq('Test advice')
    end
  end

  describe '#relationship_reading' do
    let(:question) { 'How is my relationship developing?' }
    let(:querent_name) { 'Charlie' }
    
    it 'creates a reading with relationship spread type' do
      reading = service.relationship_reading(question, querent_name)
      
      expect(reading).to be_persisted
      expect(reading.spread_type).to eq('relationship')
    end

    it 'draws exactly five cards' do
      reading = service.relationship_reading(question)
      
      expect(reading.drawn_cards.size).to eq(5)
      expect(reading.tarot_cards.size).to eq(5)
    end

    it 'assigns correct positions to cards' do
      reading = service.relationship_reading(question)
      positions = reading.drawn_cards.map { |c| c[:position] }
      
      expected_positions = ['You', 'Partner', 'Connection', 'Challenge', 'Outcome']
      expect(positions).to eq(expected_positions)
    end

    it 'calls Claude service with relationship context' do
      expect(mock_claude_service).to receive(:interpret_reading) do |cards_data, _, spread|
        expect(cards_data.size).to eq(5)
        expect(spread).to eq('relationship')
        'Test interpretation'
      end
      
      service.relationship_reading(question)
    end
  end

  describe '#recent_readings' do
    before do
      5.times do |i|
        create_test_reading(
          question: "Question #{i}",
          performed_at: i.hours.ago
        )
      end
    end

    it 'returns recent readings in descending order' do
      readings = service.recent_readings(3)
      
      expect(readings.size).to eq(3)
      times = readings.map(&:performed_at)
      expect(times).to eq(times.sort.reverse)
    end

    it 'respects the limit parameter' do
      expect(service.recent_readings(2).size).to eq(2)
      expect(service.recent_readings(10).size).to eq(5) # Only 5 exist
    end

    it 'defaults to 5 readings' do
      6.times { create_test_reading }
      readings = service.recent_readings
      expect(readings.size).to eq(5)
    end
  end

  describe '#get_reading' do
    let(:reading) { create_test_reading }

    it 'returns reading by ID' do
      result = service.get_reading(reading.id)
      expect(result).to eq(reading)
    end

    it 'returns nil for non-existent ID' do
      result = service.get_reading(999999)
      expect(result).to be_nil
    end
  end

  describe '#ask_followup' do
    let(:reading) { create_test_reading }
    let(:question) { 'Can you explain the first card more?' }

    context 'when reading exists' do
      it 'calls Claude service with reading and question' do
        expect(mock_claude_service).to receive(:ask_followup)
          .with(reading, question)
          .and_return('Followup response')
        
        result = service.ask_followup(reading.id, question)
        expect(result).to eq('Followup response')
      end
    end

    context 'when reading does not exist' do
      it 'returns nil' do
        result = service.ask_followup(999999, question)
        expect(result).to be_nil
      end

      it 'does not call Claude service' do
        expect(mock_claude_service).not_to receive(:ask_followup)
        service.ask_followup(999999, question)
      end
    end
  end

  describe 'card randomization' do
    it 'assigns random reversed status to cards' do
      # Run multiple readings to check randomization
      reversed_counts = { true => 0, false => 0 }
      
      10.times do
        reading = service.single_card_reading('Test?')
        reversed = reading.drawn_cards.first[:reversed]
        reversed_counts[reversed] += 1
      end
      
      # Both should appear at least once in 10 attempts
      expect(reversed_counts[true]).to be > 0
      expect(reversed_counts[false]).to be > 0
    end

    it 'draws different cards across readings' do
      card_ids = []
      
      5.times do
        reading = service.single_card_reading('Test?')
        card_ids << reading.drawn_cards.first[:card_id]
      end
      
      # Should have at least 2 different cards in 5 draws
      expect(card_ids.uniq.size).to be >= 2
    end
  end
end