defmodule TarotAgent.Spreads do
  alias TarotAgent.Cards

  @spreads %{
    "single" => %{
      name: "Single Card",
      description: "A simple one-card reading for quick guidance",
      positions: [
        %{name: "Guidance", description: "Your guidance for today"}
      ]
    },
    "past-present-future" => %{
      name: "Past, Present, Future",
      description: "A three-card spread showing the timeline of a situation",
      positions: [
        %{name: "Past", description: "Influences from the past"},
        %{name: "Present", description: "Current situation"},
        %{name: "Future", description: "Likely outcome"}
      ]
    },
    "celtic-cross" => %{
      name: "Celtic Cross",
      description: "A comprehensive ten-card spread for deep insight",
      positions: [
        %{name: "Present Situation", description: "The heart of the matter"},
        %{name: "Challenge", description: "What crosses or challenges you"},
        %{name: "Distant Past", description: "Foundation of the situation"},
        %{name: "Recent Past", description: "What is passing away"},
        %{name: "Possible Outcome", description: "Potential future"},
        %{name: "Near Future", description: "What is approaching"},
        %{name: "Your Approach", description: "Your role in the situation"},
        %{name: "External Influences", description: "How others see you"},
        %{name: "Hopes and Fears", description: "Your inner emotions"},
        %{name: "Final Outcome", description: "The ultimate resolution"}
      ]
    },
    "relationship" => %{
      name: "Relationship Spread",
      description: "A five-card spread for relationship insight",
      positions: [
        %{name: "You", description: "Your role in the relationship"},
        %{name: "Them", description: "Their role in the relationship"},
        %{name: "Connection", description: "The bond between you"},
        %{name: "Challenge", description: "What needs attention"},
        %{name: "Outcome", description: "The relationship's potential"}
      ]
    },
    "decision" => %{
      name: "Decision Making",
      description: "A five-card spread for making difficult choices",
      positions: [
        %{name: "Situation", description: "Current situation requiring decision"},
        %{name: "Option A", description: "First choice and its consequences"},
        %{name: "Option B", description: "Second choice and its consequences"},
        %{name: "What You Need to Know", description: "Hidden factors"},
        %{name: "Recommended Action", description: "Best path forward"}
      ]
    },
    "chakra" => %{
      name: "Chakra Alignment",
      description: "A seven-card spread for spiritual balance",
      positions: [
        %{name: "Root Chakra", description: "Foundation and security"},
        %{name: "Sacral Chakra", description: "Creativity and sexuality"},
        %{name: "Solar Plexus", description: "Personal power and confidence"},
        %{name: "Heart Chakra", description: "Love and compassion"},
        %{name: "Throat Chakra", description: "Communication and truth"},
        %{name: "Third Eye", description: "Intuition and wisdom"},
        %{name: "Crown Chakra", description: "Spiritual connection"}
      ]
    },
    "horseshoe" => %{
      name: "Horseshoe Spread",
      description: "A seven-card spread for comprehensive guidance",
      positions: [
        %{name: "Past", description: "What has led to this moment"},
        %{name: "Present", description: "Current situation"},
        %{name: "Hidden Influences", description: "What you may not see"},
        %{name: "Obstacles", description: "What stands in your way"},
        %{name: "Environment", description: "External influences"},
        %{name: "Action to Take", description: "What you should do"},
        %{name: "Outcome", description: "Likely result"}
      ]
    },
    "year-ahead" => %{
      name: "Year Ahead",
      description: "A twelve-card spread for the coming year",
      positions: [
        %{name: "January", description: "Focus for January"},
        %{name: "February", description: "Focus for February"},
        %{name: "March", description: "Focus for March"},
        %{name: "April", description: "Focus for April"},
        %{name: "May", description: "Focus for May"},
        %{name: "June", description: "Focus for June"},
        %{name: "July", description: "Focus for July"},
        %{name: "August", description: "Focus for August"},
        %{name: "September", description: "Focus for September"},
        %{name: "October", description: "Focus for October"},
        %{name: "November", description: "Focus for November"},
        %{name: "December", description: "Focus for December"}
      ]
    },
    "mind-body-spirit" => %{
      name: "Mind, Body, Spirit",
      description: "A three-card spread for holistic insight",
      positions: [
        %{name: "Mind", description: "Your mental state and thoughts"},
        %{name: "Body", description: "Your physical wellbeing"},
        %{name: "Spirit", description: "Your spiritual journey"}
      ]
    }
  }

  def get_spread(spread_name) do
    Map.get(@spreads, spread_name)
  end

  def list_spreads do
    @spreads
    |> Enum.map(fn {key, spread} ->
      "#{key}: #{spread.name} (#{length(spread.positions)} cards)"
    end)
  end

  def perform_reading(spread_name) do
    case get_spread(spread_name) do
      nil ->
        {:error, "Unknown spread: #{spread_name}"}

      spread ->
        card_count = length(spread.positions)
        cards = Cards.draw_cards(card_count)

        reading = %{
          spread: spread,
          cards: Enum.zip(spread.positions, cards),
          timestamp: DateTime.utc_now()
        }

        {:ok, reading}
    end
  end

  def format_reading(reading) do
    %{spread: spread, cards: positioned_cards} = reading

    header = """

    ═══════════════════════════════════════════════════════════════
    ✨ #{spread.name} Reading ✨
    #{spread.description}
    ═══════════════════════════════════════════════════════════════
    """

    card_interpretations =
      positioned_cards
      |> Enum.with_index(1)
      |> Enum.map(fn {{position, card}, index} ->
        # 30% chance of reversal
        reversed = :rand.uniform() < 0.3

        meaning =
          if reversed do
            "#{card.reversed_meaning} (Reversed)"
          else
            card.upright_meaning
          end

        emoji = Cards.get_card_emoji(card.name)
        reversed_symbol = if reversed, do: " ⟲", else: ""
        card_visual = if reversed do
          "#{emoji} ↑⁻¹ #{card.name}#{reversed_symbol}"
        else
          "#{emoji} #{card.name}#{reversed_symbol}"
        end
        
        """

        #{index}. #{position.name}#{reversed_symbol}
           #{position.description}
           
           #{card_visual}
           Meaning: #{meaning}
           Keywords: #{Enum.join(card.keywords, ", ")}
        """
      end)

    header <> Enum.join(card_interpretations, "\n") <> "\n"
  end
end
