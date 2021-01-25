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
    # TODO: Here we should register in the database server to be notified if the
    #       database didn't receive the expect information. If this occurs, we should 
    #       retry the collection.
    Logger.info "fna_collect_producer created with success"
    {:ok, []}
  end

  @impl true
  def handle_info(:dispatch_collector, state) do
    # Create a reference for the operations, call collectors and notify
    # the database that some data will be expected
    :erlang.make_ref
    |> create_matchbeam_collector
    |> create_fastball_collector
    |> notify_database
    # Keep the looping of creating data collectors
    Process.send_after(self(), :dispatch_collector, @fNA_COLLECT_INTERVAL)
    {:noreply, state}
  end

  ###==========================================================================
  ### Private functions
  ###==========================================================================

  defp create_matchbeam_collector(ref) do
    {:ok, _pid } =  Fna.MatchBeamSup.collect_data [ref]
    ref
  end

  defp create_fastball_collector(ref) do
    {:ok, _pid } =  Fna.FastBallSup.collect_data [ref]
    ref
  end

  defp notify_database(ref) do
    #TODO: Notify database that it should receive data from the collectors.
    #      This will allow to check if no data was receive and a new collection
    #      must be executed. The reference can be used as unique ID for the
    #      operation
  end
end