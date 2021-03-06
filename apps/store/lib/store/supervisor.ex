defmodule Store.Supervisor do
  @moduledoc false
  use Supervisor
  alias Store.{UserSupervisor, InteractionsSupervisor, FeedSupervisor}

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_args) do
    supervise(children(), strategy: :one_for_one)
  end

  defp children do
    [
      supervisor(UserSupervisor, []),
      supervisor(InteractionsSupervisor, []),
      supervisor(FeedSupervisor, [])
    ]
  end
end
