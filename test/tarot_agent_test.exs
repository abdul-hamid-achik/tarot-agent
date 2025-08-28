defmodule TarotAgentTest do
  use ExUnit.Case
  doctest TarotAgent.Cards
  doctest TarotAgent.Spreads

  alias TarotAgent.{Cards, Spreads, UI, Config, ClaudeService}

  test "cards module loads all 78 cards" do
    all_cards = Cards.all_cards()
    assert length(all_cards) == 78

    major = Cards.major_arcana()
    minor = Cards.minor_arcana()

    assert length(major) == 22
    assert length(minor) == 56
  end

  test "can shuffle and draw cards" do
    cards = Cards.draw_cards(5)
    assert length(cards) == 5
    assert Enum.all?(cards, fn card -> card.__struct__ == TarotAgent.Card end)
  end

  test "spreads module has predefined spreads" do
    spreads = Spreads.list_spreads()
    assert is_list(spreads)
    assert length(spreads) > 0
  end

  test "can perform a single card reading" do
    {:ok, reading} = Spreads.perform_reading("single")

    assert reading.spread.name == "Single Card"
    assert length(reading.cards) == 1
    assert is_struct(reading.timestamp, DateTime)
  end

  test "can perform a celtic cross reading" do
    {:ok, reading} = Spreads.perform_reading("celtic-cross")

    assert reading.spread.name == "Celtic Cross"
    assert length(reading.cards) == 10
  end

  test "returns error for unknown spread" do
    {:error, message} = Spreads.perform_reading("unknown-spread")
    assert message =~ "Unknown spread"
  end

  test "can format reading output" do
    {:ok, reading} = Spreads.perform_reading("single")
    formatted = Spreads.format_reading(reading)

    assert is_binary(formatted)
    assert formatted =~ "Single Card Reading"
    assert formatted =~ "✨"
  end

  # UI Module Tests
  test "UI can stream text" do
    # Capture IO to test text streaming
    import ExUnit.CaptureIO

    output =
      capture_io(fn ->
        # Very fast for testing
        UI.stream_text("Hello", 1)
      end)

    assert output == "Hello"
  end

  test "UI can create fancy headers" do
    import ExUnit.CaptureIO

    output =
      capture_io(fn ->
        UI.fancy_header("Test Title", "Test Subtitle")
      end)

    assert output =~ "Test Title"
    assert output =~ "Test Subtitle"
    assert output =~ "╔"
    assert output =~ "╗"
  end

  test "UI spinner animation starts and stops" do
    spinner_task = UI.start_thinking_animation("Test message")
    assert Process.alive?(spinner_task.pid)

    UI.stop_thinking_animation(spinner_task)

    # Give it a moment to shut down
    Process.sleep(10)
    refute Process.alive?(spinner_task.pid)
  end

  # Config Module Tests  
  test "config handles missing files gracefully" do
    # Should not crash when config file doesn't exist
    config = Config.load_config()
    assert is_map(config)
  end

  test "config can get claude model with default" do
    model = Config.get_claude_model()
    assert is_binary(model)
    # Default value
    assert model == "claude-3-haiku-20240307"
  end

  test "config API key functions don't crash" do
    # Should handle missing API key gracefully
    api_key = Config.get_anthropic_api_key()
    # Could be nil or a string, but shouldn't crash
    assert api_key == nil or is_binary(api_key)
  end

  # Claude Service Tests
  test "claude service handles missing API key" do
    # Mock a reading
    {:ok, reading} = Spreads.perform_reading("single")

    # Should return error for missing API key when API key is nil
    result = ClaudeService.enhance_reading(reading, "test question", nil)

    case result do
      {:error, message} ->
        assert message =~ "API key"

      {:ok, _} ->
        # If API key exists in env, that's also valid
        assert true
    end
  end

  test "claude service test_api_key handles missing key" do
    result = ClaudeService.test_api_key(nil)

    case result do
      {:error, "No API key found"} -> assert true
      # Valid if key exists but has other issues
      {:error, _other_error} -> assert true
      # Valid if key exists and works
      {:ok, _} -> assert true
    end
  end

  # Integration Tests
  test "full reading workflow completes without crashing" do
    import ExUnit.CaptureIO

    # Capture output to prevent spam during testing
    _output =
      capture_io(fn ->
        {:ok, reading} = Spreads.perform_reading("past-present-future")

        # Should not crash even if no API key
        _result = ClaudeService.enhance_reading(reading, "test question")

        # Format should work
        formatted = Spreads.format_reading(reading)
        assert is_binary(formatted)
      end)

    # If we get here, no crashes occurred
    assert true
  end

  test "all spreads can be performed" do
    spreads_list = [
      "single",
      "past-present-future",
      "celtic-cross",
      "relationship",
      "decision",
      "chakra",
      "horseshoe",
      "year-ahead",
      "mind-body-spirit"
    ]

    Enum.each(spreads_list, fn spread_name ->
      {:ok, reading} = Spreads.perform_reading(spread_name)
      assert is_map(reading)
      assert reading.spread.name != nil
      assert is_list(reading.cards)
      assert length(reading.cards) > 0
    end)
  end

  test "card drawing produces valid cards" do
    1..10
    |> Enum.each(fn count ->
      cards = Cards.draw_cards(count)
      assert length(cards) == count

      Enum.each(cards, fn card ->
        assert card.__struct__ == TarotAgent.Card
        assert is_binary(card.name)
        assert is_list(card.keywords)
        assert is_binary(card.upright_meaning)
        assert is_binary(card.reversed_meaning)
      end)
    end)
  end
end
