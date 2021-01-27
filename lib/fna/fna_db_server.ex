defmodule Fna.DbServer do
  @moduledoc """
    This module contains the server that will isolate the database information
    """
  use GenServer
  require Logger

  ###==========================================================================
  ### Local Defines
  ###==========================================================================
  @tIMEOUT_TO_RECEIVE_MG 30_000

  @timeout_msg :receive_timeout

  ###==========================================================================
  ### Types
  ###==========================================================================
  
  ###==========================================================================
  ### GenServer Callbacks
  ###==========================================================================
  
  def start_link([], timeout \\ @tIMEOUT_TO_RECEIVE_MG) do
    GenServer.start_link(__MODULE__, [timeout], [name: __MODULE__])
  end
  
  @impl true
  def init([timeout]) do
    Logger.info "#{inspect(__MODULE__)} created with success"
    {:ok, %{ ref: :undefined, n_messages: 0, 
             ref_timer: :undefined, timeout: timeout}}
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
  def handle_info(@timeout_msg, state) do
    Logger.error "Timeout, the database didn't received all expected messages"
    gproc_timeout_notify(:db_timeout)
    {:noreply, reset_values(state)}
  end

  @impl true
  def handle_call({ref, n_messages}, _from, %{ :ref_timer => :undefined } = state) do
    {:ok, t_ref} = :timer.send_after(state[:timeout], @timeout_msg)
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

  @spec send_matches(reference(), list()) :: :ok
  def send_matches(ref, matches) do
    GenServer.cast(__MODULE__, {ref, matches})
  end

  @spec update_database(reference(), integer()) :: reference()
  def update_database(ref, number_of_messages) do
    GenServer.call(__MODULE__, {ref, number_of_messages})
  end

  @spec subscribe_on_timeout() :: :new | :updated
  def subscribe_on_timeout() do
    :gproc.ensure_reg({:p,:l,{__MODULE__,:notify_on_timeout}})
  end

  ###==========================================================================
  ### Private functions
  ###==========================================================================

  defp update_state(%{ :n_messages => 1 } = state) do
    # cancel timer
    :timer.cancel(state[:t_ref])
    reset_values(state)
  end

  defp update_state(%{ :n_messages => msg } = state) do
    state
      |> Map.put(:n_messages, msg - 1)
  end

  defp reset_values(state \\ %{}) do
    state
    |> Map.put(:ref, :undefined)
    |> Map.put(:n_messages, 0)
    |> Map.put(:ref_timer, :undefined)
  end

  defp gproc_timeout_notify(msg) do
    :gproc.lookup_pids({:p,:l,{__MODULE__,:notify_on_timeout}})
    |> Enum.each( fn pid -> Process.send(pid, msg, []) end )
  end
end
