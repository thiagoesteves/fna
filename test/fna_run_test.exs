Code.require_file("test_util.exs", __DIR__)

defmodule FnaRunTest do
  use ExUnit.Case
  doctest Fna.Application

  @app_name :fna_app

  setup do
    Application.start(@app_name)
    on_exit fn -> Application.stop(@app_name) end
    :ok
  end

  test "Run app for 1 second" do
    :timer.sleep(1000)
    assert nil != Process.whereis(Fna.Supervisor)
  end
end
