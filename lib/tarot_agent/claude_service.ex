defmodule TarotAgent.ClaudeService do
  @default_model "claude-3-haiku-20240307"
  @base_url "https://api.anthropic.com/v1/messages"

  def enhance_reading(reading, question \\ nil, api_key \\ nil) do
    api_key = api_key || TarotAgent.Config.get_anthropic_api_key()

    if api_key do
      model = TarotAgent.Config.get_claude_model()
      make_claude_request(reading, question, api_key, model)
    else
      {:error, "No Anthropic API key found. Please set your API key using the config command."}
    end
  end

  defp make_claude_request(reading, question, api_key, model) do
    prompt = build_prompt(reading, question)

    body = %{
      model: model,
      max_tokens: 1000,
      messages: [
        %{
          role: "user",
          content: prompt
        }
      ]
    }

    headers = [
      {"Content-Type", "application/json"},
      {"x-api-key", api_key},
      {"anthropic-version", "2023-06-01"}
    ]

    case Req.post(@base_url, json: body, headers: headers) do
      {:ok, %{status: 200, body: response}} ->
        case extract_response_text(response) do
          {:ok, text} -> {:ok, text}
          {:error, reason} -> {:error, "Failed to parse response: #{reason}"}
        end

      {:ok, %{status: status, body: body}} ->
        error_msg = extract_error_message(body)
        {:error, "API request failed (#{status}): #{error_msg}"}

      {:error, reason} ->
        {:error, "Network error: #{inspect(reason)}"}
    end
  end

  defp build_prompt(reading, question) do
    %{spread: spread, cards: positioned_cards} = reading

    question_context =
      if question do
        "The querent asked: \"#{question}\"\n\n"
      else
        ""
      end

    cards_description =
      Enum.map_join(positioned_cards, "\n\n", fn {position, card} ->
        "Position: #{position.name} (#{position.description})\nCard: #{card.name}\nKeywords: #{Enum.join(card.keywords, ", ")}"
      end)

    """
    You are an expert tarot reader providing insightful and meaningful interpretations. 

    #{question_context}The reading was done using the #{spread.name} spread: #{spread.description}

    Here are the cards drawn:

    #{cards_description}

    Please provide a cohesive, insightful interpretation that:
    1. Connects the cards meaningfully within the context of their positions
    2. Addresses the question if one was asked
    3. Offers practical guidance and reflection
    4. Maintains a supportive and empowering tone
    5. Highlights key themes and patterns in the reading

    Keep the response focused and meaningful, around 200-300 words.
    """
  end

  defp extract_response_text(%{"content" => [%{"text" => text} | _]}), do: {:ok, text}
  defp extract_response_text(%{"content" => content}) when is_binary(content), do: {:ok, content}
  defp extract_response_text(_), do: {:error, "Unexpected response format"}

  defp extract_error_message(%{"error" => %{"message" => message}}), do: message
  defp extract_error_message(%{"error" => error}) when is_binary(error), do: error
  defp extract_error_message(_), do: "Unknown error"

  def test_api_key(api_key \\ nil) do
    api_key = api_key || TarotAgent.Config.get_anthropic_api_key()

    if api_key do
      test_prompt = "Please respond with 'API key is working' if you can read this message."

      body = %{
        model: @default_model,
        max_tokens: 50,
        messages: [
          %{
            role: "user",
            content: test_prompt
          }
        ]
      }

      headers = [
        {"Content-Type", "application/json"},
        {"x-api-key", api_key},
        {"anthropic-version", "2023-06-01"}
      ]

      case Req.post(@base_url, json: body, headers: headers) do
        {:ok, %{status: 200}} ->
          {:ok, "API key is valid and working"}

        {:ok, %{status: status, body: body}} ->
          error_msg = extract_error_message(body)
          {:error, "API key test failed (#{status}): #{error_msg}"}

        {:error, reason} ->
          {:error, "Network error during API key test: #{inspect(reason)}"}
      end
    else
      {:error, "No API key found"}
    end
  end
end
