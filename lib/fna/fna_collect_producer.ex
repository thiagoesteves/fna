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
  @fNA_COLLECT_INTERVAL 1000

  ###==========================================================================
  ### Types
  ###==========================================================================
  
  ###==========================================================================
  ### GenServer Callbacks
  ###==========================================================================
  
  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: :fna_collect_producer)
  end
  
  @impl true
  def init([]) do
    # Start the collectors dispatching
    Process.send(self(), :dispatch_collector, [])
    Logger.info "fna_collect_producer created with success"
    {:ok, []}
  end

  @impl true
  def handle_info(:dispatch_collector, state) do
    # Create collectors
    create_matchbeam_collector()
    create_fastball_collector()
    # Notify database
    notify_database()
    # Keep the looping of creating data collectors
    Process.send_after(self(), :dispatch_collector, @fNA_COLLECT_INTERVAL)
    {:noreply, state}
  end

  ###==========================================================================
  ### Private functions
  ###==========================================================================

  defp create_matchbeam_collector() do
    #TODO: implement the creation here
  end

  defp create_fastball_collector() do
    #TODO: implement the creation here
  end

  defp notify_database() do
    #TODO: Notify database that it should receive data from the collectors
    #      this will allow to check if no data was receive and a new collection
    #      must be executed
  end
end