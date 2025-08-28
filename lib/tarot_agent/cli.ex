defmodule TarotAgent.CLI do
  alias TarotAgent.{ClaudeService, Config, Spreads}

  def main(args) do
    case args do
      [] ->
        show_help()

      [command | rest] ->
        handle_command(command, rest)
    end
  end

  defp handle_command("help", _), do: show_help()
  defp handle_command("--help", _), do: show_help()
  defp handle_command("-h", _), do: show_help()

  defp handle_command("config", args) do
    case args do
      ["set-api-key"] ->
        set_api_key()

      ["set-model", model] ->
        set_claude_model(model)

      ["test"] ->
        test_api_connection()

      [] ->
        show_config()

      _ ->
        IO.puts("Usage: config [set-api-key|set-model MODEL|test]")
    end
  end

  defp handle_command("spreads", _) do
    IO.puts("\nAvailable Spreads:")
    IO.puts("==================")

    Spreads.list_spreads()
    |> Enum.each(&IO.puts("• #{&1}"))

    IO.puts("")
  end

  defp handle_command("reading", args) do
    case args do
      [] ->
        interactive_reading()

      [spread_name] ->
        perform_reading(spread_name, nil)

      [spread_name | question_words] ->
        question = Enum.join(question_words, " ")
        perform_reading(spread_name, question)
    end
  end

  # Handle direct spread names as commands
  defp handle_command(spread_name, question_words) do
    if Spreads.get_spread(spread_name) do
      question =
        case question_words do
          [] -> nil
          words -> Enum.join(words, " ")
        end

      perform_reading(spread_name, question)
    else
      IO.puts("Unknown command: #{spread_name}")
      IO.puts("Use 'help' to see available commands.")
    end
  end

  defp show_help do
    IO.puts("""

    🔮 Tarot Agent - Your AI-Enhanced Tarot Reading CLI
    ================================================

    COMMANDS:
      help                    Show this help message
      spreads                 List available tarot spreads
      config                  Show current configuration
      config set-api-key      Set your Anthropic API key for AI readings
      config set-model MODEL  Set Claude model (default: claude-3-haiku-20240307)
      config test             Test API connection
      reading                 Start interactive reading selection
      reading SPREAD [QUESTION]  Perform a specific spread reading

    AVAILABLE SPREADS:
      single                  Single card guidance
      past-present-future     Three card timeline reading
      celtic-cross           Comprehensive 10-card reading
      relationship           5-card relationship insight
      decision               5-card decision making spread
      chakra                 7-card chakra alignment
      horseshoe              7-card comprehensive guidance
      year-ahead             12-card yearly forecast
      mind-body-spirit       3-card holistic insight

    EXAMPLES:
      tarot_agent reading single
      tarot_agent celtic-cross "What should I focus on this month?"
      tarot_agent relationship "How can I improve my relationship?"
      tarot_agent config set-api-key

    For AI-enhanced interpretations, set your Anthropic API key:
      tarot_agent config set-api-key
    """)
  end

  defp interactive_reading do
    IO.puts("\n🔮 Welcome to Interactive Tarot Reading")
    IO.puts("=====================================")

    IO.puts("\nAvailable spreads:")

    Spreads.list_spreads()
    |> Enum.each(&IO.puts("• #{&1}"))

    spread_name = ExPrompt.string("\nWhich spread would you like? ") |> String.trim()

    case Spreads.get_spread(spread_name) do
      nil ->
        IO.puts("Unknown spread. Please choose from the list above.")

      _spread ->
        question =
          ExPrompt.string("Optional: What question do you have? (press Enter to skip) ")
          |> String.trim()

        final_question = if question == "", do: nil, else: question

        IO.puts("\n🎴 Shuffling cards and drawing your reading...")
        perform_reading_with_spread(spread_name, final_question)
    end
  end

  defp perform_reading(spread_name, question) do
    case Spreads.get_spread(spread_name) do
      nil ->
        IO.puts("Unknown spread: #{spread_name}")
        IO.puts("Use 'spreads' command to see available options.")

      _spread ->
        perform_reading_with_spread(spread_name, question)
    end
  end

  defp perform_reading_with_spread(spread_name, question) do
    case Spreads.perform_reading(spread_name) do
      {:ok, reading} ->
        # Show basic reading
        IO.puts(Spreads.format_reading(reading))

        # Try to get AI enhancement
        case ClaudeService.enhance_reading(reading, question) do
          {:ok, ai_interpretation} ->
            IO.puts("═══════════════════════════════════════════════════════════════")
            IO.puts("🤖 AI-Enhanced Interpretation")
            IO.puts("═══════════════════════════════════════════════════════════════")
            IO.puts(ai_interpretation)
            IO.puts("")

          {:error, reason} ->
            IO.puts("\n⚠️  Note: #{reason}")
            IO.puts("Reading complete without AI enhancement.")
            IO.puts("Use 'config set-api-key' to enable AI interpretations.")
        end

      {:error, reason} ->
        IO.puts("Error performing reading: #{reason}")
    end
  end

  defp set_api_key do
    IO.puts("Please enter your Anthropic API key:")
    IO.puts("(You can get one at: https://console.anthropic.com/)")

    api_key = ExPrompt.password("API Key: ") |> String.trim()

    if String.length(api_key) > 0 do
      case Config.set_anthropic_api_key(api_key) do
        {:ok, message} ->
          IO.puts("✓ #{message}")

          # Test the API key
          IO.puts("Testing API connection...")

          case ClaudeService.test_api_key(api_key) do
            {:ok, _} -> IO.puts("✓ API key is working correctly!")
            {:error, reason} -> IO.puts("⚠️  Warning: #{reason}")
          end

        {:error, reason} ->
          IO.puts("✗ Error: #{reason}")
      end
    else
      IO.puts("No API key entered.")
    end
  end

  defp set_claude_model(model) do
    case Config.set_claude_model(model) do
      {:ok, message} -> IO.puts("✓ #{message}")
      {:error, reason} -> IO.puts("✗ Error: #{reason}")
    end
  end

  defp test_api_connection do
    IO.puts("Testing API connection...")

    case ClaudeService.test_api_key() do
      {:ok, message} -> IO.puts("✓ #{message}")
      {:error, reason} -> IO.puts("✗ #{reason}")
    end
  end

  defp show_config do
    api_key = Config.get_anthropic_api_key()
    model = Config.get_claude_model()

    IO.puts("\nCurrent Configuration:")
    IO.puts("======================")
    IO.puts("Claude Model: #{model}")

    if api_key do
      masked_key = String.slice(api_key, 0, 8) <> "..." <> String.slice(api_key, -4, 4)
      IO.puts("API Key: #{masked_key} ✓")
    else
      IO.puts("API Key: Not set ✗")
      IO.puts("\nTo set your API key: tarot_agent config set-api-key")
    end

    IO.puts("")
  end
end
