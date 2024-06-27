defmodule Player.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {Player.Api, name: Player.Api},
      {DynamicSupervisor, name: Player.BucketSupervisor, strategy: :one_for_one},
      {Task.Supervisor, name: Player.RouterTasks}


    ]
    Supervisor.init(children, strategy: :one_for_all)
  end
end
