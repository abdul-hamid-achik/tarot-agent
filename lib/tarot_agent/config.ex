defmodule TarotAgent.Config do
  @config_dir Path.join([System.user_home(), ".tarot_agent"])
  @config_file Path.join(@config_dir, "config.json")
  @env_file ".env"

  def ensure_config_dir do
    unless File.exists?(@config_dir) do
      File.mkdir_p!(@config_dir)
    end
  end

  def get_anthropic_api_key do
    get_api_key_from_env() ||
      get_api_key_from_config() ||
      get_api_key_from_system_env()
  end

  def set_anthropic_api_key(api_key) when is_binary(api_key) do
    ensure_config_dir()

    config = load_config()
    updated_config = Map.put(config, "anthropic_api_key", api_key)

    case Jason.encode(updated_config, pretty: true) do
      {:ok, json} ->
        case File.write(@config_file, json) do
          :ok -> {:ok, "API key saved successfully"}
          {:error, reason} -> {:error, "Failed to save config: #{reason}"}
        end

      {:error, reason} ->
        {:error, "Failed to encode config: #{reason}"}
    end
  end

  def get_claude_model do
    get_config_value("claude_model", "claude-3-haiku-20240307")
  end

  def set_claude_model(model) when is_binary(model) do
    set_config_value("claude_model", model)
  end

  def load_config do
    if File.exists?(@config_file) do
      case File.read(@config_file) do
        {:ok, content} ->
          case Jason.decode(content) do
            {:ok, config} -> config
            {:error, _} -> %{}
          end

        {:error, _} ->
          %{}
      end
    else
      %{}
    end
  end

  defp get_api_key_from_env do
    if File.exists?(@env_file) do
      case File.read(@env_file) do
        {:ok, content} ->
          case DotenvParser.parse_data(content) do
            {:ok, env_vars} ->
              env_map =
                case env_vars do
                  list when is_list(list) -> Map.new(list)
                  map when is_map(map) -> map
                  _ -> %{}
                end

              Map.get(env_map, "ANTHROPIC_API_KEY") ||
                Map.get(env_map, "CLAUDE_API_KEY") ||
                Map.get(env_map, "TAROT_AGENT_ANTHROPIC_API_KEY")

            {:error, _} ->
              nil

            result ->
              # Handle unexpected return format - convert list to map if needed
              case result do
                list when is_list(list) ->
                  env_map = Map.new(list)

                  Map.get(env_map, "ANTHROPIC_API_KEY") ||
                    Map.get(env_map, "CLAUDE_API_KEY") ||
                    Map.get(env_map, "TAROT_AGENT_ANTHROPIC_API_KEY")

                _ ->
                  nil
              end
          end

        {:error, _} ->
          nil
      end
    end
  end

  defp get_api_key_from_config do
    config = load_config()
    Map.get(config, "anthropic_api_key")
  end

  defp get_api_key_from_system_env do
    System.get_env("ANTHROPIC_API_KEY") || System.get_env("CLAUDE_API_KEY")
  end

  defp get_config_value(key, default) do
    config = load_config()
    Map.get(config, key, default)
  end

  defp set_config_value(key, value) do
    ensure_config_dir()

    config = load_config()
    updated_config = Map.put(config, key, value)

    case Jason.encode(updated_config, pretty: true) do
      {:ok, json} ->
        case File.write(@config_file, json) do
          :ok -> {:ok, "#{key} saved successfully"}
          {:error, reason} -> {:error, "Failed to save config: #{reason}"}
        end

      {:error, reason} ->
        {:error, "Failed to encode config: #{reason}"}
    end
  end
end
