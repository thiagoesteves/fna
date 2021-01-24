defmodule FnaAppTest do
  use ExUnit.Case
  doctest Fna.Application

  @app_name :fna_app

  setup do
    Application.stop(@app_name)
    :ok = Application.start(@app_name)
    :ok
  end

  test "check Application is running" do
    assert nil != Process.whereis(Fna.Supervisor)
  end

  test "check Application is already started" do
    assert {:error, {:already_started, _}} = Fna.Application.start(:none, :none)
  end
end
