defmodule TarotAgent.CLI do
  alias TarotAgent.{ClaudeService, Config, Spreads, IntelligentParser, UI}

  def main(args) do
    case args do
      [] ->
        show_interactive_help()

      args ->
        input = Enum.join(args, " ")
        handle_intelligent_input(input)
    end
  end

  defp handle_intelligent_input(input) do
    case IntelligentParser.parse_command(input) do
      {:command, "help", _} ->
        show_help()
        
      {:command, "spreads", _} ->
        show_spreads()
        
      {:command, "config", args} ->
        handle_config_command(args)
        
      {:command, "reading", args} ->
        case args do
          [] -> interactive_reading()
          [question] when is_binary(question) ->
            # If they provided a question with "reading", suggest a spread
            IO.puts("💡 I see you want a reading with the question: \"#{question}\"")
            IO.puts("Let me suggest some spreads:")
            show_suggested_spreads_for_question(question)
          _ -> interactive_reading()
        end
        
      {:spread, spread_name, question} ->
        UI.fancy_header("🎴 #{spread_name |> String.replace("-", " ") |> String.split() |> Enum.map(&String.capitalize/1) |> Enum.join(" ")} Reading", 
                       if(question, do: "Question: #{question}", else: "Let the cards guide you"))
        perform_reading(spread_name, question)
        
      {:suggestion, :list_spreads, message} ->
        IO.puts("💡 #{message}")
        show_spreads()
        
      {:suggestion, :question_with_reading, {question}} ->
        IO.puts("💡 I see you want a reading with the question: \"#{question}\"")
        IO.puts("Let me suggest some spreads:")
        show_suggested_spreads_for_question(question)
        
      {:interactive_clarify, original_input} ->
        case IntelligentParser.interactive_clarification(original_input) do
          {:spread, spread_name, question} -> 
            perform_reading(spread_name, question)
          {:command, command, args} -> 
            handle_legacy_command(command, args)
        end
        
      _ ->
        IntelligentParser.smart_error_with_suggestions(input)
    end
  end

  # Legacy command handlers for backward compatibility  
  defp handle_legacy_command("help", _), do: show_help()
  defp handle_legacy_command("--help", _), do: show_help()
  defp handle_legacy_command("-h", _), do: show_help()

  defp handle_config_command(args) do
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

  defp show_spreads do
    UI.fancy_header("🔮 Available Tarot Spreads", "Choose your path to wisdom")

    spreads_info = [
      {"single", "Single Card", "Quick daily guidance"},
      {"past-present-future", "Past, Present, Future", "Timeline insight"},  
      {"celtic-cross", "Celtic Cross", "Comprehensive 10-card reading"},
      {"relationship", "Relationship", "Love and partnership guidance"},
      {"decision", "Decision Making", "Help with difficult choices"},
      {"chakra", "Chakra Alignment", "Spiritual energy balance"},
      {"horseshoe", "Horseshoe", "General life guidance"},
      {"year-ahead", "Year Ahead", "12-month forecast"},
      {"mind-body-spirit", "Mind, Body, Spirit", "Holistic wellness insight"}
    ]

    spreads_info
    |> Enum.each(fn {key, name, desc} ->
      IO.puts("🎴 #{IO.ANSI.cyan()}#{key}#{IO.ANSI.reset()} - #{name}")
      IO.puts("   #{desc}")
      IO.puts("")
    end)

    IO.puts("💡 #{IO.ANSI.yellow()}Examples:#{IO.ANSI.reset()}")
    IO.puts("   tarot_agent celtic cross \"What should I focus on?\"")
    IO.puts("   tarot_agent single card")
    IO.puts("   tarot_agent relationship reading")
    IO.puts("")
  end

  defp show_interactive_help do
    UI.fancy_header("🔮 Welcome to Tarot Agent", "Your AI-Enhanced Tarot Reading CLI")
    
    IO.puts("I understand natural language! Try any of these:")
    IO.puts("")
    
    IO.puts("🎴 #{IO.ANSI.cyan()}Quick Readings:#{IO.ANSI.reset()}")
    IO.puts("   • tarot_agent single")
    IO.puts("   • tarot_agent quick reading")
    IO.puts("   • tarot_agent one card")
    IO.puts("")
    
    IO.puts("🎴 #{IO.ANSI.cyan()}Detailed Readings:#{IO.ANSI.reset()}")
    IO.puts("   • tarot_agent celtic cross")
    IO.puts("   • tarot_agent comprehensive reading")
    IO.puts("   • tarot_agent ten card spread")
    IO.puts("")
    
    IO.puts("🎴 #{IO.ANSI.cyan()}With Questions:#{IO.ANSI.reset()}")
    IO.puts("   • tarot_agent love reading \"How is my relationship?\"")
    IO.puts("   • tarot_agent decision \"Should I take this job?\"")
    IO.puts("   • tarot_agent timeline \"What's coming up?\"")
    IO.puts("")
    
    IO.puts("⚙️ #{IO.ANSI.cyan()}Configuration:#{IO.ANSI.reset()}")
    IO.puts("   • tarot_agent config set-api-key")
    IO.puts("   • tarot_agent settings")
    IO.puts("")
    
    IO.puts("📋 #{IO.ANSI.cyan()}Information:#{IO.ANSI.reset()}")
    IO.puts("   • tarot_agent spreads")
    IO.puts("   • tarot_agent help")
    IO.puts("")
    
    IO.puts("✨ #{IO.ANSI.yellow()}I'm smart! I understand variations like:#{IO.ANSI.reset()}")
    IO.puts("   'celtic cross' = 'celtic-cross' = 'comprehensive' = '10 card'")
    IO.puts("")
  end

  defp show_suggested_spreads_for_question(question) do
    IO.puts("")
    IO.puts("🎴 #{IO.ANSI.cyan()}Quick Options:#{IO.ANSI.reset()}")
    IO.puts("   • #{IO.ANSI.yellow()}single#{IO.ANSI.reset()} - Quick daily guidance")
    IO.puts("   • #{IO.ANSI.yellow()}celtic cross#{IO.ANSI.reset()} - Comprehensive 10-card reading")
    IO.puts("   • #{IO.ANSI.yellow()}past present future#{IO.ANSI.reset()} - Timeline insight")
    IO.puts("")
    IO.puts("💬 Try: #{IO.ANSI.cyan()}tarot_agent single \"#{question}\"#{IO.ANSI.reset()}")
    IO.puts("💬 Or:  #{IO.ANSI.cyan()}tarot_agent celtic cross \"#{question}\"#{IO.ANSI.reset()}")
    IO.puts("")
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

    spread_input = ExPrompt.string("\nWhich spread would you like? ") |> String.trim()

    # Use intelligent parser to find the spread
    case IntelligentParser.find_spread(spread_input) do
      nil ->
        IO.puts("\n❌ I didn't understand \"#{spread_input}\"")
        suggestions = IntelligentParser.suggest_spread_alternatives(spread_input)
        
        if length(suggestions) > 0 do
          IO.puts("\n💡 Did you mean:")
          suggestions
          |> Enum.take(2)
          |> Enum.each(fn spread ->
            spread_info = Spreads.get_spread(spread)
            IO.puts("   • #{spread} (#{spread_info.name})")
          end)
        end

      spread_name ->
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

        # Try to get AI enhancement with streaming
        case ClaudeService.enhance_reading(reading, question) do
          {:ok, _} ->
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
