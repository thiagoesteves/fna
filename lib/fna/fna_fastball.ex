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
  @server_name      "FastBall"

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
        %{ "matches" => map_body } = Poison.decode!(body)
        unified_map = map_body
        |> Flow.from_enumerable()
        |> Flow.partition()
        |> Flow.map(fn match -> match |> normalize_data(@server_name) end)
        |> Enum.to_list
        Logger.info "FastBall Data Collected with success #{inspect(unified_map)}"
        send_to_database(unified_map)
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

  defp normalize_data(match, server_name) do
    Fna.Util.create_match(server_name, 
                          match["home_team"],
                          match["away_team"],
                          match["created_at"],
                          match["kickoff_at"])
  end

  defp send_to_database(_msg) do
    # TODO
  end
end
