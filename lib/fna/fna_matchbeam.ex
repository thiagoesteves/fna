defmodule Fna.MatchBeam do
  @moduledoc """
    This module contains the server that will request data from MatchBeam server
    """
  use GenServer
  require Logger

  ###==========================================================================
  ### Local Defines
  ###==========================================================================

  # Server address definitions
  @matchbeam_address 'http://forzaassignment.forzafootball.com:8080/feed/matchbeam'
  @server_name       "MatchBeam"

  # Timeouts
  @tIME_TO_RETRY     1000

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
    Logger.info @server_name <> " Collector started #{inspect(ref)}"
    {:ok, ref}
  end

  @impl true
  def handle_info(:collect_data, state) do
     case Fna.Util.capture_data(@matchbeam_address) do
      {:ok, body} ->
        %{ "matches" => map_body } = Poison.decode!(body)
        unified_map = map_body
        |> Flow.from_enumerable()
        |> Flow.partition()
        |> Flow.map(fn match -> match |> normalize_data(@server_name) end)
        |> Enum.to_list
        Logger.info @server_name <> " - #{inspect(length unified_map)} matches collected with success"
        # send to database
        Fna.DbServer.send_matches(state, unified_map)
        {:stop, :normal, state}
      _           -> 
        # TODO: insert a counter in the state to allow a maximum number 
        #       of retries
        Logger.error @server_name <> " Data unavailable, retry"
        Process.send_after(self(), :collect_data, @tIME_TO_RETRY)
        {:noreply, state}
    end
  end

  ###==========================================================================
  ### Private functions
  ###==========================================================================

  defp normalize_data(match, server_name) do
    [home_team, away_team] = String.split(match["teams"], " - ")
    Fna.Util.create_match(server_name, 
                          home_team,
                          away_team,
                          match["created_at"],
                          match["kickoff_at"])
  end
end