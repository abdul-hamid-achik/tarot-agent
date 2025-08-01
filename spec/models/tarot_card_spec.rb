# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TarotAgent::Models::TarotCard do
  # Test validations
  describe 'validations' do
    it 'requires a name' do
      card = described_class.new(arcana: 'major')
      expect(card).not_to be_valid
      expect(card.errors[:name]).to include("can't be blank")
    end

    it 'requires a unique name' do
      create_test_card(name: 'The Fool')
      duplicate = described_class.new(name: 'The Fool', arcana: 'major')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include('has already been taken')
    end

    it 'requires arcana to be major or minor' do
      card = described_class.new(name: 'Test', arcana: 'invalid')
      expect(card).not_to be_valid
      expect(card.errors[:arcana]).to include('is not included in the list')
    end

    it 'validates suit only for specific values' do
      card = described_class.new(name: 'Test', arcana: 'minor', suit: 'invalid')
      expect(card).not_to be_valid
      expect(card.errors[:suit]).to include('is not included in the list')
    end

    it 'allows valid suit values' do
      %w[cups wands swords pentacles].each do |suit|
        card = described_class.new(name: "Test #{suit}", arcana: 'minor', suit: suit)
        card.valid?
        expect(card.errors[:suit]).to be_empty
      end
    end
  end

  # Test scopes
  describe 'scopes' do
    before do
      create_test_card(name: 'Major 1', arcana: 'major')
      create_test_card(name: 'Major 2', arcana: 'major')
      create_test_card(name: 'Minor Cups', arcana: 'minor', suit: 'cups')
      create_test_card(name: 'Minor Wands', arcana: 'minor', suit: 'wands')
    end

    describe '.major_arcana' do
      it 'returns only major arcana cards' do
        cards = described_class.major_arcana
        expect(cards.count).to be >= 2
        expect(cards.all? { |c| c.arcana == 'major' }).to be true
      end
    end

    describe '.minor_arcana' do
      it 'returns only minor arcana cards' do
        cards = described_class.minor_arcana
        expect(cards.count).to be >= 2
        expect(cards.all? { |c| c.arcana == 'minor' }).to be true
      end
    end

    describe '.by_suit' do
      it 'returns cards of specified suit' do
        cards = described_class.by_suit('cups')
        expect(cards.count).to be >= 1
        expect(cards.all? { |c| c.suit == 'cups' }).to be true
      end
    end

    describe '.by_element' do
      it 'returns cards of specified element' do
        create_test_card(name: 'Water Card', element: 'Water')
        cards = described_class.by_element('Water')
        expect(cards.count).to be >= 1
        expect(cards.all? { |c| c.element == 'Water' }).to be true
      end
    end
  end

  # Test instance methods
  describe 'instance methods' do
    let(:major_card) { create_test_card(name: 'The Test', arcana: 'major') }
    let(:minor_card) { create_test_card(name: 'Three', arcana: 'minor', suit: 'cups') }

    describe '#major?' do
      it 'returns true for major arcana' do
        expect(major_card.major?).to be true
      end

      it 'returns false for minor arcana' do
        expect(minor_card.major?).to be false
      end
    end

    describe '#minor?' do
      it 'returns true for minor arcana' do
        expect(minor_card.minor?).to be true
      end

      it 'returns false for major arcana' do
        expect(major_card.minor?).to be false
      end
    end

    describe '#full_name' do
      it 'returns name for major arcana' do
        expect(major_card.full_name).to eq('The Test')
      end

      it 'returns name with suit for minor arcana' do
        expect(minor_card.full_name).to eq('Three of Cups')
      end
    end

    describe '#keywords_array' do
      it 'splits keywords into array' do
        card = create_test_card(keywords: 'love, harmony, balance')
        expect(card.keywords_array).to eq(['love', 'harmony', 'balance'])
      end

      it 'handles nil keywords' do
        card = create_test_card(keywords: nil)
        expect(card.keywords_array).to eq([])
      end
    end

    describe '#random_meaning' do
      it 'returns either upright or reversed meaning' do
        card = create_test_card(
          upright_meaning: 'Upright',
          reversed_meaning: 'Reversed'
        )
        
        meanings = []
        10.times { meanings << card.random_meaning }
        
        expect(meanings).to include('Upright')
        expect(meanings).to include('Reversed')
      end
    end

    describe '#to_display' do
      it 'returns formatted display hash' do
        card = create_test_card(
          name: 'Display Test',
          arcana: 'major',
          keywords: 'test, display',
          element: 'Fire',
          astrological_sign: 'Aries'
        )
        
        display = card.to_display
        
        expect(display).to include(
          name: 'Display Test',
          arcana: 'major',
          keywords: ['test', 'display'],
          element: 'Fire',
          astrological_sign: 'Aries'
        )
      end
    end
  end

  # Test class methods
  describe 'class methods' do
    before do
      # Ensure we have some cards
      3.times { |i| create_test_card(name: "Card #{i}") }
    end

    describe '.draw_random' do
      it 'returns a single card' do
        card = described_class.draw_random
        expect(card).to be_a(described_class)
      end

      it 'returns different cards on multiple calls' do
        cards = []
        10.times { cards << described_class.draw_random&.id }
        cards.compact!
        
        # Should have at least 2 different cards in 10 draws
        expect(cards.uniq.size).to be >= 2
      end
    end

    describe '.draw_cards' do
      it 'returns specified number of cards' do
        cards = described_class.draw_cards(2)
        expect(cards.count).to eq(2)
      end

      it 'returns unique cards' do
        cards = described_class.draw_cards(3)
        expect(cards.map(&:id).uniq.size).to eq(3)
      end

      it 'handles request for more cards than available' do
        total = described_class.count
        cards = described_class.draw_cards(total + 10)
        expect(cards.count).to eq(total)
      end
    end
  end
end