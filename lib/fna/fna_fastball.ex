defmodule Fna.FastBall do
  @moduledoc """
    This module contains the server that will request data from FastBall server
    """
  use GenServer
  require Logger

  ###==========================================================================
  ### Local Defines
  ###==========================================================================

  # Server address definitions
  @fastball_address 'http://forzaassignment.forzafootball.com:8080/feed/fastball'

  # Timeouts
  @tIME_TO_RETRY    1000

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
    Logger.info "FastBall Collector started #{inspect(ref)}"
    {:ok, ref}
  end

  @impl true
  def handle_info(:collect_data, state) do
     case Fna.Util.capture_data(@fastball_address) do
      {:ok, body} -> 
        Logger.info "FastBall Data Collected with success #{inspect(body)}"
        normalize_data(body)
        |> send_to_database
        {:stop, :normal, state}
      _           -> 
        # TODO: insert a counter in the state to allow a maximum number 
        #       of retries
        Logger.error "FastBall Data unavailable, retry"
        Process.send_after(self(), :collect_data, @tIME_TO_RETRY)
        {:noreply, state}
    end
  end

  ###==========================================================================
  ### Private functions
  ###==========================================================================

  defp normalize_data(_body) do
    # TODO
  end

  defp send_to_database(_msg) do
    # TODO
  end
end
