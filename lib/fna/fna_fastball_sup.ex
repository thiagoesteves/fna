defmodule Fna.FastBallSup do
  @moduledoc """
    This supervisor will handle all servers that will be created to collect data
    for FastBall
    """
  use DynamicSupervisor
  require Logger

  def start_link([]) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init([]) do
    Logger.info "Fna.FastBallSup created with success"
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  ###==========================================================================
  ### Public API functions
  ###==========================================================================
  @spec collect_data(list()) :: { :ok , pid() }
  def collect_data(args) do
    spec = %{id: Fna.FastBall, start: {Fna.FastBall, :start_link, [args]}, restart: :transient}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
