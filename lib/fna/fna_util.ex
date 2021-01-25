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
end