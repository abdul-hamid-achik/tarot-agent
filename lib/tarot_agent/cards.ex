defmodule TarotAgent.Card do
  defstruct [
    :id,
    :name,
    :arcana,
    :number,
    :suit,
    :keywords,
    :upright_meaning,
    :reversed_meaning,
    :description,
    :element,
    :astrology
  ]
end

defmodule TarotAgent.Cards do
  alias TarotAgent.Card

  @major_arcana [
    %Card{
      id: 0,
      name: "The Fool",
      arcana: :major,
      number: 0,
      keywords: ["beginnings", "innocence", "spontaneity"],
      upright_meaning: "New beginnings, innocence, spontaneity",
      reversed_meaning: "Recklessness, taken advantage of, inconsideration"
    },
    %Card{
      id: 1,
      name: "The Magician",
      arcana: :major,
      number: 1,
      keywords: ["manifestation", "resourcefulness", "power"],
      upright_meaning: "Manifestation, resourcefulness, power, inspired action",
      reversed_meaning: "Manipulation, poor planning, untapped talents"
    },
    %Card{
      id: 2,
      name: "The High Priestess",
      arcana: :major,
      number: 2,
      keywords: ["intuition", "sacred knowledge", "divine feminine"],
      upright_meaning: "Intuition, sacred knowledge, divine feminine, the subconscious mind",
      reversed_meaning: "Secrets, disconnected from intuition, withdrawal and silence"
    },
    %Card{
      id: 3,
      name: "The Empress",
      arcana: :major,
      number: 3,
      keywords: ["femininity", "beauty", "nature"],
      upright_meaning: "Femininity, beauty, nature, nurturing, abundance",
      reversed_meaning: "Creative block, dependence on others"
    },
    %Card{
      id: 4,
      name: "The Emperor",
      arcana: :major,
      number: 4,
      keywords: ["authority", "establishment", "structure"],
      upright_meaning: "Authority, establishment, structure, a father figure",
      reversed_meaning: "Domination, excessive control, lack of discipline, inflexibility"
    },
    %Card{
      id: 5,
      name: "The Hierophant",
      arcana: :major,
      number: 5,
      keywords: ["spiritual wisdom", "religious beliefs", "conformity"],
      upright_meaning: "Spiritual wisdom, religious beliefs, conformity, tradition, institutions",
      reversed_meaning: "Personal beliefs, freedom, challenging the status quo"
    },
    %Card{
      id: 6,
      name: "The Lovers",
      arcana: :major,
      number: 6,
      keywords: ["love", "harmony", "relationships"],
      upright_meaning: "Love, harmony, relationships, values alignment, choices",
      reversed_meaning: "Self-love, disharmony, imbalance, misalignment of values"
    },
    %Card{
      id: 7,
      name: "The Chariot",
      arcana: :major,
      number: 7,
      keywords: ["control", "willpower", "success"],
      upright_meaning: "Control, willpower, success, determination, direction",
      reversed_meaning: "Self-discipline, opposition, lack of direction"
    },
    %Card{
      id: 8,
      name: "Strength",
      arcana: :major,
      number: 8,
      keywords: ["strength", "courage", "persuasion"],
      upright_meaning: "Strength, courage, persuasion, influence, compassion",
      reversed_meaning: "Self doubt, lack of confidence, lack of self-discipline"
    },
    %Card{
      id: 9,
      name: "The Hermit",
      arcana: :major,
      number: 9,
      keywords: ["soul searching", "introspection", "inner guidance"],
      upright_meaning: "Soul searching, introspection, being alone, inner guidance",
      reversed_meaning: "Isolation, loneliness, withdrawal"
    },
    %Card{
      id: 10,
      name: "Wheel of Fortune",
      arcana: :major,
      number: 10,
      keywords: ["good luck", "karma", "life cycles"],
      upright_meaning: "Good luck, karma, life cycles, destiny, a turning point",
      reversed_meaning: "Bad luck, lack of control, clinging to control, external forces"
    },
    %Card{
      id: 11,
      name: "Justice",
      arcana: :major,
      number: 11,
      keywords: ["justice", "fairness", "truth"],
      upright_meaning: "Justice, fairness, truth, cause and effect, law",
      reversed_meaning: "Unfairness, lack of accountability, dishonesty"
    },
    %Card{
      id: 12,
      name: "The Hanged Man",
      arcana: :major,
      number: 12,
      keywords: ["suspension", "restriction", "letting go"],
      upright_meaning: "Suspension, restriction, letting go, sacrifice",
      reversed_meaning: "Martyrdom, indecision, delay"
    },
    %Card{
      id: 13,
      name: "Death",
      arcana: :major,
      number: 13,
      keywords: ["endings", "beginnings", "change"],
      upright_meaning: "Endings, beginnings, change, transformation, transition",
      reversed_meaning: "Resistance to change, personal transformation, inner purging"
    },
    %Card{
      id: 14,
      name: "Temperance",
      arcana: :major,
      number: 14,
      keywords: ["balance", "moderation", "patience"],
      upright_meaning: "Balance, moderation, patience, purpose",
      reversed_meaning: "Imbalance, excess, self-healing, re-alignment"
    },
    %Card{
      id: 15,
      name: "The Devil",
      arcana: :major,
      number: 15,
      keywords: ["bondage", "addiction", "sexuality"],
      upright_meaning: "Bondage, addiction, sexuality, materialism",
      reversed_meaning: "Releasing limiting beliefs, exploring dark thoughts, detachment"
    },
    %Card{
      id: 16,
      name: "The Tower",
      arcana: :major,
      number: 16,
      keywords: ["sudden change", "upheaval", "chaos"],
      upright_meaning: "Sudden change, upheaval, chaos, revelation, awakening",
      reversed_meaning: "Personal transformation, fear of change, averting disaster"
    },
    %Card{
      id: 17,
      name: "The Star",
      arcana: :major,
      number: 17,
      keywords: ["hope", "faith", "purpose"],
      upright_meaning: "Hope, faith, purpose, renewal, spirituality",
      reversed_meaning: "Lack of faith, despair, self-trust, disconnection"
    },
    %Card{
      id: 18,
      name: "The Moon",
      arcana: :major,
      number: 18,
      keywords: ["illusion", "fear", "anxiety"],
      upright_meaning: "Illusion, fear, anxiety, subconscious, intuition",
      reversed_meaning: "Release of fear, repressed emotion, inner confusion"
    },
    %Card{
      id: 19,
      name: "The Sun",
      arcana: :major,
      number: 19,
      keywords: ["positivity", "fun", "warmth"],
      upright_meaning: "Positivity, fun, warmth, success, vitality, joy",
      reversed_meaning: "Inner child, feeling down, overly optimistic"
    },
    %Card{
      id: 20,
      name: "Judgement",
      arcana: :major,
      number: 20,
      keywords: ["judgement", "rebirth", "inner calling"],
      upright_meaning: "Judgement, rebirth, inner calling, forgiveness",
      reversed_meaning: "Self-doubt, harsh judgement, lack of self-awareness"
    },
    %Card{
      id: 21,
      name: "The World",
      arcana: :major,
      number: 21,
      keywords: ["completion", "accomplishment", "travel"],
      upright_meaning: "Completion, accomplishment, travel, the end of a journey",
      reversed_meaning: "Seeking personal closure, short-cuts, delays"
    }
  ]

  @minor_arcana_suits [:wands, :cups, :swords, :pentacles]
  @court_cards [:page, :knight, :queen, :king]
  @pip_cards 1..10

  def minor_arcana do
    pip_cards =
      for suit <- @minor_arcana_suits,
          number <- @pip_cards do
        suit_meanings = get_suit_meanings(suit)

        %Card{
          id: get_card_id(:minor, suit, number),
          name: "#{number} of #{String.capitalize(Atom.to_string(suit))}",
          arcana: :minor,
          suit: suit,
          number: number,
          keywords: suit_meanings.keywords,
          upright_meaning: "#{suit_meanings.upright} - #{get_number_meaning(number)}",
          reversed_meaning:
            "#{suit_meanings.reversed} - Blocked or excessive #{get_number_meaning(number)}",
          element: suit_meanings.element
        }
      end

    court_cards =
      for suit <- @minor_arcana_suits,
          court <- @court_cards do
        suit_meanings = get_suit_meanings(suit)
        court_meanings = get_court_meanings(court)

        %Card{
          id: get_card_id(:minor, suit, court),
          name:
            "#{String.capitalize(Atom.to_string(court))} of #{String.capitalize(Atom.to_string(suit))}",
          arcana: :minor,
          suit: suit,
          number: court,
          keywords: court_meanings.keywords ++ suit_meanings.keywords,
          upright_meaning: "#{court_meanings.upright} in #{suit_meanings.upright}",
          reversed_meaning: "#{court_meanings.reversed} or #{suit_meanings.reversed}",
          element: suit_meanings.element
        }
      end

    pip_cards ++ court_cards
  end

  def all_cards, do: @major_arcana ++ minor_arcana()

  def major_arcana, do: @major_arcana

  def get_card(id) do
    Enum.find(all_cards(), &(&1.id == id))
  end

  def shuffle_deck do
    all_cards() |> Enum.shuffle()
  end

  def draw_cards(count) when count > 0 do
    shuffle_deck() |> Enum.take(count)
  end

  defp get_suit_meanings(:wands) do
    %{
      keywords: ["creativity", "inspiration", "energy"],
      upright: "Creativity, inspiration, action, growth",
      reversed: "Lack of energy, lack of passion, boredom",
      element: :fire
    }
  end

  defp get_suit_meanings(:cups) do
    %{
      keywords: ["emotion", "intuition", "relationships"],
      upright: "Emotion, intuition, spirituality, love",
      reversed: "Emotional instability, uncontrolled feelings",
      element: :water
    }
  end

  defp get_suit_meanings(:swords) do
    %{
      keywords: ["thought", "communication", "conflict"],
      upright: "Thought, communication, intellect, power",
      reversed: "Confusion, brutality, chaos",
      element: :air
    }
  end

  defp get_suit_meanings(:pentacles) do
    %{
      keywords: ["material", "practical", "physical"],
      upright: "Material world, practical matters, career, money",
      reversed: "Over-materialism, lack of growth, stinginess",
      element: :earth
    }
  end

  defp get_court_meanings(:page) do
    %{
      keywords: ["student", "messenger", "earth"],
      upright: "Student, eager to learn",
      reversed: "Inexperience, lack of commitment"
    }
  end

  defp get_court_meanings(:knight) do
    %{
      keywords: ["action", "adventure", "impulsiveness"],
      upright: "Action-oriented, adventurous",
      reversed: "Impulsiveness, haste, recklessness"
    }
  end

  defp get_court_meanings(:queen) do
    %{
      keywords: ["nurturing", "intuitive", "practical"],
      upright: "Nurturing, intuitive, practical",
      reversed: "Self-care neglect, smothering, unreliable"
    }
  end

  defp get_court_meanings(:king) do
    %{
      keywords: ["leadership", "maturity", "control"],
      upright: "Leadership, maturity, control",
      reversed: "Tyranny, manipulation, domination"
    }
  end

  defp get_number_meaning(1), do: "new beginnings, raw energy"
  defp get_number_meaning(2), do: "balance, cooperation, partnerships"
  defp get_number_meaning(3), do: "creativity, groups, growth"
  defp get_number_meaning(4), do: "stability, structure, foundations"
  defp get_number_meaning(5), do: "conflict, challenges, instability"
  defp get_number_meaning(6), do: "communication, cooperation, harmony"
  defp get_number_meaning(7), do: "reflection, assessment, knowledge"
  defp get_number_meaning(8), do: "mastery, action, achievement"
  defp get_number_meaning(9), do: "attainment, fulfillment, completion"
  defp get_number_meaning(10), do: "end of cycle, renewal, fresh start"

  defp get_card_id(:minor, suit, number) when is_integer(number) do
    base =
      case suit do
        :wands -> 22
        :cups -> 36
        :swords -> 50
        :pentacles -> 64
      end

    base + number - 1
  end

  defp get_card_id(:minor, suit, court) do
    base =
      case suit do
        :wands -> 32
        :cups -> 46
        :swords -> 60
        :pentacles -> 74
      end

    offset =
      case court do
        :page -> 0
        :knight -> 1
        :queen -> 2
        :king -> 3
      end

    base + offset
  end
end
