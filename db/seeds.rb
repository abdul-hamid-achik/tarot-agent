# frozen_string_literal: true

require_relative '../config/database'
require_relative '../lib/tarot_agent/models/tarot_card'

# Connect to database
TarotAgent::Database.connect!

# Clear existing cards
TarotAgent::Models::TarotCard.destroy_all
puts "Cleared existing tarot cards"

# Seed Major Arcana cards (0-21)
major_arcana = [
  {
    name: "The Fool",
    number: 0,
    arcana: "major",
    keywords: "new beginnings, innocence, spontaneity, free spirit",
    upright_meaning: "New beginnings, optimism, trust in life, innocence, freedom",
    reversed_meaning: "Recklessness, risk-taking, foolishness, lack of direction",
    element: "Air",
    description: "The Fool represents new beginnings and having faith in the future"
  },
  {
    name: "The Magician",
    number: 1,
    arcana: "major",
    keywords: "manifestation, resourcefulness, power, inspired action",
    upright_meaning: "Manifestation, willpower, desire, creation, skill",
    reversed_meaning: "Manipulation, poor planning, untapped talents, illusion",
    element: "Air",
    astrological_sign: "Mercury",
    description: "The Magician represents manifestation and using your gifts"
  },
  {
    name: "The High Priestess",
    number: 2,
    arcana: "major",
    keywords: "intuition, sacred knowledge, divine feminine, subconscious",
    upright_meaning: "Intuition, sacred knowledge, divine feminine, higher power",
    reversed_meaning: "Secrets, disconnected from intuition, withdrawal, silence",
    element: "Water",
    astrological_sign: "Moon",
    description: "The High Priestess represents intuition and inner wisdom"
  },
  {
    name: "The Empress",
    number: 3,
    arcana: "major",
    keywords: "femininity, beauty, nature, nurturing, abundance",
    upright_meaning: "Femininity, beauty, nature, nurturing, creativity",
    reversed_meaning: "Creative block, dependence on others, emptiness",
    element: "Earth",
    astrological_sign: "Venus",
    description: "The Empress represents feminine power and abundance"
  },
  {
    name: "The Emperor",
    number: 4,
    arcana: "major",
    keywords: "authority, structure, control, father figure",
    upright_meaning: "Authority, establishment, structure, father figure",
    reversed_meaning: "Tyranny, rigidity, coldness, domination",
    element: "Fire",
    astrological_sign: "Aries",
    description: "The Emperor represents authority and structure"
  },
  {
    name: "The Hierophant",
    number: 5,
    arcana: "major",
    keywords: "tradition, conformity, morality, ethics, wisdom",
    upright_meaning: "Spiritual wisdom, religious beliefs, conformity, tradition",
    reversed_meaning: "Personal beliefs, freedom, challenging the status quo",
    element: "Earth",
    astrological_sign: "Taurus",
    description: "The Hierophant represents traditional values and wisdom"
  },
  {
    name: "The Lovers",
    number: 6,
    arcana: "major",
    keywords: "love, harmony, relationships, values, choices",
    upright_meaning: "Love, harmony, relationships, values alignment",
    reversed_meaning: "Disharmony, imbalance, misalignment of values",
    element: "Air",
    astrological_sign: "Gemini",
    description: "The Lovers represents relationships and choices"
  },
  {
    name: "The Chariot",
    number: 7,
    arcana: "major",
    keywords: "control, willpower, success, determination, ambition",
    upright_meaning: "Control, willpower, success, determination",
    reversed_meaning: "Lack of control, lack of direction, aggression",
    element: "Water",
    astrological_sign: "Cancer",
    description: "The Chariot represents triumph through maintaining control"
  },
  {
    name: "Strength",
    number: 8,
    arcana: "major",
    keywords: "inner strength, courage, patience, control, compassion",
    upright_meaning: "Inner strength, courage, patience, compassion",
    reversed_meaning: "Self doubt, weakness, insecurity, low energy",
    element: "Fire",
    astrological_sign: "Leo",
    description: "Strength represents inner courage and patience"
  },
  {
    name: "The Hermit",
    number: 9,
    arcana: "major",
    keywords: "soul searching, introspection, inner guidance, solitude",
    upright_meaning: "Soul searching, introspection, being alone, inner guidance",
    reversed_meaning: "Isolation, loneliness, withdrawal, anti-social",
    element: "Earth",
    astrological_sign: "Virgo",
    description: "The Hermit represents soul searching and inner guidance"
  },
  {
    name: "Wheel of Fortune",
    number: 10,
    arcana: "major",
    keywords: "good luck, karma, life cycles, destiny, turning point",
    upright_meaning: "Good luck, karma, life cycles, destiny, fortune",
    reversed_meaning: "Bad luck, lack of control, clinging to control",
    element: "Fire",
    astrological_sign: "Jupiter",
    description: "The Wheel of Fortune represents cycles and destiny"
  },
  {
    name: "Justice",
    number: 11,
    arcana: "major",
    keywords: "justice, fairness, truth, cause and effect, law",
    upright_meaning: "Justice, fairness, truth, cause and effect",
    reversed_meaning: "Unfairness, lack of accountability, dishonesty",
    element: "Air",
    astrological_sign: "Libra",
    description: "Justice represents fairness and truth"
  },
  {
    name: "The Hanged Man",
    number: 12,
    arcana: "major",
    keywords: "surrender, letting go, new perspective, sacrifice",
    upright_meaning: "Surrender, sacrifice, letting go, new perspective",
    reversed_meaning: "Resistance, stalling, indecision, avoiding sacrifice",
    element: "Water",
    astrological_sign: "Neptune",
    description: "The Hanged Man represents letting go and new perspective"
  },
  {
    name: "Death",
    number: 13,
    arcana: "major",
    keywords: "endings, beginnings, change, transformation, transition",
    upright_meaning: "Endings, transformation, transition, letting go",
    reversed_meaning: "Resistance to change, inability to move on, fear",
    element: "Water",
    astrological_sign: "Scorpio",
    description: "Death represents transformation and new beginnings"
  },
  {
    name: "Temperance",
    number: 14,
    arcana: "major",
    keywords: "balance, moderation, patience, purpose, meaning",
    upright_meaning: "Balance, moderation, patience, purpose",
    reversed_meaning: "Imbalance, excess, lack of long-term vision",
    element: "Fire",
    astrological_sign: "Sagittarius",
    description: "Temperance represents balance and moderation"
  },
  {
    name: "The Devil",
    number: 15,
    arcana: "major",
    keywords: "bondage, addiction, sexuality, materialism, powerlessness",
    upright_meaning: "Bondage, addiction, sexuality, materialism",
    reversed_meaning: "Releasing limiting beliefs, exploring dark thoughts",
    element: "Earth",
    astrological_sign: "Capricorn",
    description: "The Devil represents bondage and materialism"
  },
  {
    name: "The Tower",
    number: 16,
    arcana: "major",
    keywords: "sudden change, upheaval, chaos, revelation, awakening",
    upright_meaning: "Sudden change, upheaval, chaos, revelation",
    reversed_meaning: "Personal transformation, fear of change, averting disaster",
    element: "Fire",
    astrological_sign: "Mars",
    description: "The Tower represents sudden upheaval and revelation"
  },
  {
    name: "The Star",
    number: 17,
    arcana: "major",
    keywords: "hope, faith, purpose, renewal, spirituality",
    upright_meaning: "Hope, faith, purpose, renewal, healing",
    reversed_meaning: "Lack of faith, despair, disconnection",
    element: "Air",
    astrological_sign: "Aquarius",
    description: "The Star represents hope and spiritual guidance"
  },
  {
    name: "The Moon",
    number: 18,
    arcana: "major",
    keywords: "illusion, fear, anxiety, subconscious, intuition",
    upright_meaning: "Illusion, fear, anxiety, insecurity, subconscious",
    reversed_meaning: "Release of fear, repressed emotion, inner confusion",
    element: "Water",
    astrological_sign: "Pisces",
    description: "The Moon represents illusions and the subconscious"
  },
  {
    name: "The Sun",
    number: 19,
    arcana: "major",
    keywords: "joy, success, celebration, positivity, vitality",
    upright_meaning: "Joy, success, celebration, positivity",
    reversed_meaning: "Inner child, feeling down, overly optimistic",
    element: "Fire",
    astrological_sign: "Sun",
    description: "The Sun represents success and vitality"
  },
  {
    name: "Judgement",
    number: 20,
    arcana: "major",
    keywords: "reflection, reckoning, inner calling, absolution",
    upright_meaning: "Judgement, rebirth, inner calling, absolution",
    reversed_meaning: "Self doubt, inability to forgive, harsh judgement",
    element: "Fire",
    astrological_sign: "Pluto",
    description: "Judgement represents reflection and reckoning"
  },
  {
    name: "The World",
    number: 21,
    arcana: "major",
    keywords: "completion, accomplishment, travel, closure, fulfillment",
    upright_meaning: "Completion, accomplishment, travel, unity",
    reversed_meaning: "Incompletion, no closure, incomplete goals",
    element: "Earth",
    astrological_sign: "Saturn",
    description: "The World represents completion and accomplishment"
  }
]

# Create Major Arcana cards
major_arcana.each do |card_data|
  TarotAgent::Models::TarotCard.create!(card_data)
  puts "Created: #{card_data[:name]}"
end

# Sample Minor Arcana cards (just Aces for brevity - you can expand this)
minor_arcana_samples = [
  {
    name: "Ace of Cups",
    number: 1,
    arcana: "minor",
    suit: "cups",
    keywords: "new emotions, spirituality, intuition, creativity",
    upright_meaning: "New relationships, compassion, creativity",
    reversed_meaning: "Self-love, intuition, repressed emotions",
    element: "Water",
    description: "The Ace of Cups represents new emotional beginnings"
  },
  {
    name: "Ace of Wands",
    number: 1,
    arcana: "minor",
    suit: "wands",
    keywords: "inspiration, new opportunities, growth, potential",
    upright_meaning: "Inspiration, new opportunities, growth",
    reversed_meaning: "Lack of energy, delays, lack of passion",
    element: "Fire",
    description: "The Ace of Wands represents new inspiration and growth"
  },
  {
    name: "Ace of Swords",
    number: 1,
    arcana: "minor",
    suit: "swords",
    keywords: "new ideas, mental clarity, breakthrough, justice",
    upright_meaning: "Mental clarity, breakthrough, new ideas",
    reversed_meaning: "Inner clarity, re-thinking an idea, clouded judgement",
    element: "Air",
    description: "The Ace of Swords represents mental clarity and breakthrough"
  },
  {
    name: "Ace of Pentacles",
    number: 1,
    arcana: "minor",
    suit: "pentacles",
    keywords: "new opportunity, resources, abundance, manifestation",
    upright_meaning: "New financial opportunity, manifestation",
    reversed_meaning: "Lost opportunity, lack of planning",
    element: "Earth",
    description: "The Ace of Pentacles represents material opportunities"
  }
]

# Create sample Minor Arcana cards
minor_arcana_samples.each do |card_data|
  TarotAgent::Models::TarotCard.create!(card_data)
  puts "Created: #{card_data[:name]} of #{card_data[:suit].capitalize}"
end

puts "\nSeeding complete! Created #{TarotAgent::Models::TarotCard.count} tarot cards."