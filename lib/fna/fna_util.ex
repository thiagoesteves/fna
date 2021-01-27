defmodule Fna.Util do
  @moduledoc """
    This module contains functions that can be used by all modules
    """

  ###==========================================================================
  ### Public functions
  ###==========================================================================
  
  @spec capture_data(list()) :: { :ok, list() } | { :error , :service_unavailable }
  def capture_data(address) do
    case :httpc.request(:get, {address, []}, [], []) do
      {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} -> 
        {:ok, body}
      {:ok, {{'HTTP/1.1', 503, 'Service Unavailable'}, _headers, _body}} -> 
        {:error, :service_unavailable}
      {:ok, {{'HTTP/1.1', 400, _}, _headers, _body}} -> 
        {:error, :invalid_params}
    end
  end

  @spec create_match(binary(), binary(), binary(), integer(), binary()) :: %Fna.Match{}
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

  @spec persist(%Fna.Match{}) :: :inserted | :already
  def persist(match) do
    case Fna.Match.changeset(match, %{}) |> Fna.Repo.insert() do
      {:ok, _} -> 
        :inserted
      {:error, changeset} ->
        # guarantee unique id error
        true = match_taken?(changeset.errors)
        :already
    end
  end

  @spec match_taken?(tuple()) :: true | false
  defp match_taken?([id: {_, [constraint: :unique, constraint_name: _]}]), do: true
  defp match_taken?(_), do: false
end
