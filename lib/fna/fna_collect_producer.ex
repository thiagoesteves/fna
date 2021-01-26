defmodule Fna.CollectProducer do
  @moduledoc """
    This module contains the server that will dispatch collectors periodically
    to retrieve football information
    """
  use GenServer
  require Logger

  ###==========================================================================
  ### Local Defines
  ###==========================================================================
  @fNA_COLLECT_INTERVAL 10000

  @number_of_matches_server 2

  ###==========================================================================
  ### Types
  ###==========================================================================
  
  ###==========================================================================
  ### GenServer Callbacks
  ###==========================================================================
  
  def start_link([]) do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end
  
  @impl true
  def init([]) do
    # Start the collectors dispatching
    Process.send(self(), :dispatch_collector, [])
    # subscribe to observe if the database has any timeout
    Fna.DbServer.subscribe_on_timeout
    Logger.info "#{inspect(__MODULE__)} created with success"
    {:ok, %{ last_checked_time: 0, ref_timer: :undefined}}
  end

  @impl true
  def handle_info(:dispatch_collector, state) do
    # this timestamp will be saved to the next round to collect matches
    # occured only after it (FastBall)
    new_time = :os.system_time(:second)
    # Create servers to collect matches
    create_collectors(state[:last_checked_time])
    # Keep the loop
    {:ok, t_ref} = :timer.send_after(@fNA_COLLECT_INTERVAL, :dispatch_collector)
    {:noreply, state
               |> Map.put(:last_checked_time, new_time)
               |> Map.put(:ref_timer, t_ref) }
  end

  def handle_info(:db_timeout, state) do
    Logger.error "Database had a timeout, retry"
    # Cancel current timer
    :timer.cancel(state[:ref_timer])
    # Create servers again with the previous information
    create_collectors(state[:last_checked_time])
    # Keep the loop
    {:ok, t_ref} = :timer.send_after(@fNA_COLLECT_INTERVAL, :dispatch_collector)
    {:noreply, state |> Map.put(:ref_timer, t_ref) }
  end

  ###==========================================================================
  ### Private functions
  ###==========================================================================

  # Create a reference for the operations, call collectors and notify
  # the database that some data will be expected
  defp create_collectors(last_time) do
    :erlang.make_ref
    |> create_matchbeam_collector
    |> create_fastball_collector(last_time)
    |> Fna.DbServer.update_database(@number_of_matches_server)
  end

  defp create_matchbeam_collector(ref) do
    {:ok, _pid } =  Fna.MatchBeamSup.collect_data [ref]
    ref
  end

  defp create_fastball_collector(ref, last_checked_time) do
    {:ok, _pid } =  Fna.FastBallSup.collect_data [ref, last_checked_time]
    ref
  end
end
