defmodule Fna.Util do
  @moduledoc """
    This module contains functions that can be used by all modules
    """

  ###==========================================================================
  ### Public functions
  ###==========================================================================

  def capture_data(address) do
    case :httpc.request(:get, {address, []}, [], []) do
      {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} -> 
        {:ok, body}
      {:ok, {{'HTTP/1.1', 503, 'Service Unavailable'}, _headers, _body}} -> 
        {:error, :service_unavailable}
    end
  end

  def create_match(server_name, home_team, away_team, created_at, kickoff_at) do
    {:ok, kickoff, 0} = DateTime.from_iso8601(kickoff_at)
    {:ok, created}    = DateTime.from_unix(created_at)

    %Fna.Match{
      server_name: server_name,
      home_team: home_team,
      away_team: away_team,
      kickoff_at: kickoff,
      created_at: created
    }
  end

  def persist(match) do
    case Fna.Match.changeset(match, %{}) |> Fna.Repo.insert() do
      {:ok, inserted_match} -> 
        inserted_match
      {:error, changeset} -> # already taken
        :none
    end
  end

  defp match_taken?({:id, {_, [constraint: :unique, constraint_name: _]}}), do: true
  defp match_taken?(_), do: false
end