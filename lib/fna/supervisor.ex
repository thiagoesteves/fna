defmodule Fna.Supervisor do
  @moduledoc """
    This supervisor will handle the gen_server and/or other supervisor
    for this application
    """
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init([]) do
    children = [
      Fna.CollectProducer
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end

end
