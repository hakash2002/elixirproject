defmodule Player do
  use Application

  @impl true
  def start(_type, _args) do
    Player.Supervisor.start_link(name: Player.Supervisor)
  end
end
