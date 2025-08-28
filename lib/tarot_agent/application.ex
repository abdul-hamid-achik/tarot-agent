defmodule TarotAgent.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Add any supervised processes here if needed in the future
    ]

    opts = [strategy: :one_for_one, name: TarotAgent.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
