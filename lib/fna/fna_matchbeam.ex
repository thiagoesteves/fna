defmodule Fna.MatchBeam do
  @moduledoc """
    This module contains the server that will request data from MatchBeam server
    """
  use GenServer
  require Logger

  ###==========================================================================
  ### Local Defines
  ###==========================================================================

  ###==========================================================================
  ### Types
  ###==========================================================================
  
  ###==========================================================================
  ### GenServer Callbacks
  ###==========================================================================
  
  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end
  
  @impl true
  def init([ref]) do
    # Start the collectors dispatching
    Process.send(self(), :collect_data, [])
    Logger.info "MatchBeam Collector started #{inspect(ref)}"
    {:ok, ref}
  end

  @impl true
  def handle_info(:collect_data, state) do
    # Create collectors
    capture_data()
    Logger.info "MatchBeam Data Collected with success"
    {:stop, :normal, state}
  end

  ###==========================================================================
  ### Private functions
  ###==========================================================================

  defp capture_data() do
    #TODO: implement the creation here
  end
end