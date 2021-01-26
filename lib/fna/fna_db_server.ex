defmodule Fna.DbServer do
  @moduledoc """
    This module contains the server that will isolate the database information
    """
  use GenServer
  require Logger

  ###==========================================================================
  ### Local Defines
  ###==========================================================================
  @tIMEOUT_TO_RECEIVE_MG 3000

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
    {:ok, clean_state()}
  end

  @impl true
  def handle_cast({ref, matches}, %{ :ref => ref } = state) do
    # Persist the information in the database
    new_matchs = matches
    |> Enum.map(fn match -> match |> Fna.Util.persist end)
    |> Enum.count(&(&1 == :inserted))
    Logger.info "#{inspect(new_matchs)} new matches were added to the database"
    {:noreply, update_state(state)}
  end

  def handle_cast(_, %{ :n_messages => 0 } = state) do
    Logger.error "No messages are expected"
    {:noreply, state}
  end

  def handle_cast({ref, _}, state) do
    Logger.error "Invalid reference: received #{inspect(ref)}, expected #{inspect(state[:ref])}"
    {:noreply, state}
  end

  @impl true
  def handle_info(:timeout, state) do
    Logger.error "Timeout, the database didn't received all expected messages"
    # TODO: add a notification for timeout, so any observer could subscribe
    #       and retry the operation
    {:noreply, clean_state()}
  end

  @impl true
  def handle_call({ref, n_messages}, _from, state) do
    {:ok, t_ref} = :timer.send_after(@tIMEOUT_TO_RECEIVE_MG, :timeout)
    new_state = 
      state
      |> Map.put(:ref, ref)
      |> Map.put(:n_messages, n_messages)
      |> Map.put(:ref_timer, t_ref)
    {:reply, ref, new_state}
  end

  ###==========================================================================
  ### Public functions
  ###==========================================================================

  def send_matches(ref, matches) do
    GenServer.cast(__MODULE__, {ref, matches})
  end

  def update_database(ref, number_of_messages) do
    GenServer.call(__MODULE__, {ref, number_of_messages})
  end

  ###==========================================================================
  ### Private functions
  ###==========================================================================

  defp update_state(%{ :n_messages => 1, ref_timer: t_ref } = state) do
    # cancel timer
    :timer.cancel(t_ref)
    clean_state()
  end

  defp update_state(%{ :n_messages => msg } = state) do
    state
      |> Map.put(:n_messages, msg - 1)
  end

  defp clean_state() do
    %{ ref: :undefined, n_messages: 0, ref_timer: :undefined}
  end
end