# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TarotAgent::Models::Reading do
  # Test validations
  describe 'validations' do
    it 'requires a question' do
      reading = described_class.new
      expect(reading).not_to be_valid
      expect(reading.errors[:question]).to include("can't be blank")
    end

    it 'validates spread_type values' do
      reading = described_class.new(question: 'Test?', spread_type: 'invalid')
      expect(reading).not_to be_valid
      expect(reading.errors[:spread_type]).to include('is not included in the list')
    end

    it 'allows valid spread types' do
      valid_types = %w[single three_card celtic_cross past_present_future relationship]
      valid_types.each do |type|
        reading = described_class.new(question: 'Test?', spread_type: type)
        reading.valid?
        expect(reading.errors[:spread_type]).to be_empty
      end
    end
  end

  # Test callbacks
  describe 'callbacks' do
    describe 'before_create' do
      it 'sets performed_at if not provided' do
        reading = create_test_reading(performed_at: nil)
        expect(reading.performed_at).not_to be_nil
        expect(reading.performed_at).to be_within(1.second).of(Time.current)
      end

      it 'preserves performed_at if provided' do
        time = 1.day.ago
        reading = create_test_reading(performed_at: time)
        expect(reading.performed_at).to be_within(1.second).of(time)
      end
    end
  end

  # Test scopes
  describe 'scopes' do
    before do
      create_test_reading(performed_at: 3.days.ago)
      create_test_reading(performed_at: 1.day.ago)
      create_test_reading(performed_at: 1.hour.ago)
    end

    describe '.recent' do
      it 'orders by performed_at descending' do
        readings = described_class.recent
        times = readings.map(&:performed_at)
        expect(times).to eq(times.sort.reverse)
      end
    end

    describe '.by_spread' do
      before do
        create_test_reading(spread_type: 'single')
        create_test_reading(spread_type: 'three_card')
        create_test_reading(spread_type: 'three_card')
      end

      it 'filters by spread type' do
        readings = described_class.by_spread('three_card')
        expect(readings.count).to eq(2)
        expect(readings.all? { |r| r.spread_type == 'three_card' }).to be true
      end
    end

    describe '.today' do
      before do
        create_test_reading(performed_at: Time.current)
        create_test_reading(performed_at: 1.day.ago)
      end

      it 'returns only today\'s readings' do
        readings = described_class.today
        expect(readings.count).to be >= 1
        expect(readings.all? { |r| r.performed_at.to_date == Date.current }).to be true
      end
    end
  end

  # Test instance methods
  describe 'instance methods' do
    let(:reading) { create_test_reading }
    let(:card1) { create_test_card(name: 'Card 1') }
    let(:card2) { create_test_card(name: 'Card 2') }

    describe '#drawn_cards and #drawn_cards=' do
      it 'stores and retrieves cards as JSON' do
        cards_data = [
          { card_id: 1, position: 0, reversed: false },
          { card_id: 2, position: 1, reversed: true }
        ]
        
        reading.drawn_cards = cards_data
        reading.save!
        
        expect(reading.drawn_cards).to eq(cards_data)
      end

      it 'handles empty array' do
        reading.drawn_cards = []
        expect(reading.drawn_cards).to eq([])
      end

      it 'handles nil cards_drawn' do
        reading.cards_drawn = nil
        expect(reading.drawn_cards).to eq([])
      end

      it 'handles invalid JSON gracefully' do
        reading.cards_drawn = 'invalid json'
        expect(reading.drawn_cards).to eq([])
      end
    end

    describe '#add_card' do
      it 'adds a card to the reading' do
        reading.add_card(card1, 'Past')
        cards = reading.drawn_cards
        
        expect(cards.size).to eq(1)
        expect(cards.first[:card_id]).to eq(card1.id)
        expect(cards.first[:position]).to eq('Past')
      end

      it 'auto-assigns position if not provided' do
        reading.add_card(card1)
        reading.add_card(card2)
        
        cards = reading.drawn_cards
        expect(cards[0][:position]).to eq(0)
        expect(cards[1][:position]).to eq(1)
      end

      it 'randomly assigns reversed status' do
        reversed_statuses = []
        10.times do
          r = create_test_reading
          r.add_card(card1)
          reversed_statuses << r.drawn_cards.first[:reversed]
        end
        
        # Should have both true and false in 10 attempts
        expect(reversed_statuses).to include(true)
        expect(reversed_statuses).to include(false)
      end
    end

    describe '#tarot_cards' do
      it 'returns TarotCard objects for drawn cards' do
        reading.add_card(card1)
        reading.add_card(card2)
        reading.save!
        
        cards = reading.tarot_cards
        expect(cards).to include(card1)
        expect(cards).to include(card2)
      end

      it 'returns empty array when no cards drawn' do
        expect(reading.tarot_cards).to eq([])
      end
    end

    describe '#interpreted?' do
      it 'returns false when no interpretation' do
        expect(reading.interpreted?).to be false
      end

      it 'returns true when interpretation exists' do
        reading.claude_interpretation = 'Test interpretation'
        expect(reading.interpreted?).to be true
      end
    end

    describe '#spread_description' do
      it 'returns correct description for each spread type' do
        descriptions = {
          'single' => 'Single Card Draw',
          'three_card' => 'Three Card Spread',
          'celtic_cross' => 'Celtic Cross Spread',
          'past_present_future' => 'Past, Present, Future',
          'relationship' => 'Relationship Spread'
        }
        
        descriptions.each do |type, description|
          reading.spread_type = type
          expect(reading.spread_description).to eq(description)
        end
      end

      it 'returns Custom Spread for unknown types' do
        reading.spread_type = nil
        expect(reading.spread_description).to eq('Custom Spread')
      end
    end

    describe '#to_display' do
      it 'returns formatted display hash' do
        reading = create_test_reading(
          question: 'Test question?',
          spread_type: 'single',
          claude_interpretation: 'Test interpretation',
          claude_advice: 'Test advice'
        )
        reading.add_card(card1)
        reading.save!
        
        display = reading.to_display
        
        expect(display).to include(
          id: reading.id,
          question: 'Test question?',
          spread: 'Single Card Draw',
          interpretation: 'Test interpretation',
          advice: 'Test advice'
        )
        expect(display[:cards]).to include(card1.full_name)
        expect(display[:performed_at]).to match(/\w+ \d+, \d+ at \d+:\d+ [AP]M/)
      end
    end
  end
end