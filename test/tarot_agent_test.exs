defmodule TarotAgentTest do
  use ExUnit.Case
  doctest TarotAgent.Cards
  doctest TarotAgent.Spreads

  alias TarotAgent.{Cards, Spreads}

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
end
