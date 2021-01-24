defmodule Fna.DbServer do
  @moduledoc """
    This module contains the server that will isolate the database information
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
  
  def start_link([]) do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end
  
  @impl true
  def init([]) do
    Logger.info "fna_db_server created with success"
    {:ok, []}
  end

  @impl true
  def handle_call(msg, _from, state) do
    response = {:ok, msg}
    Logger.info "handle_call with success"
    {:reply, response, state}
  end

  ###==========================================================================
  ### Public functions
  ###==========================================================================

  def save_news(msg) do
    GenServer.call(__MODULE__, msg)
  end

  ###==========================================================================
  ### Private functions
  ###==========================================================================
end