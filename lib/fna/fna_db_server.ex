defmodule Fna.DbServer do
  @moduledoc """
    This module contains the server that will isolate the database information
    """
  use GenServer
  require Logger

  ###==========================================================================
  ### Local Defines
  ###==========================================================================
  @tIMEOUT_TO_RECEIVE_MG 30000

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
    Logger.info "#{inspect(__MODULE__)} created with success"
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
  def handle_info(:timeout, _) do
    Logger.error "Timeout, the database didn't received all expected messages"
    gproc_timeout_notify(:db_timeout)
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

  def subscribe_on_timeout() do
    :gproc.ensure_reg({:p,:l,{__MODULE__,:notify_on_timeout}})
  end

  ###==========================================================================
  ### Private functions
  ###==========================================================================

  defp update_state(%{ :n_messages => 1, ref_timer: t_ref }) do
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

  defp gproc_timeout_notify(msg) do
    :gproc.lookup_pids({:p,:l,{__MODULE__,:notify_on_timeout}})
    |> Enum.each( fn pid -> Process.send(pid, msg, []) end )
  end
end
