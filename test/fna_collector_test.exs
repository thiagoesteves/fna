defmodule FnaCollectorTest do
  use ExUnit.Case
  doctest Fna.Application

  @app_name :fna_app

  setup do
    Application.stop(@app_name)
    :ok
  end

  test "Check that if the MatchBeam server crashes, it will be restored" do
  end

  test "Check that if the MatchBeam server return != :normal, it will be restored" do
  end

  test "Check that if the FastBall server crashes, it will be restored" do
  end

  test "Check that if the FastBall server return != :normal, it will be restored" do
  end
end
