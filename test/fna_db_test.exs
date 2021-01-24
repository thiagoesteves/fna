defmodule FnaDbTest do
  use ExUnit.Case
  doctest Fna.Application

  @app_name :fna_app

  setup do
    Application.stop(@app_name)
    :ok
  end

  test "Check that the server receives information from both server FastBall and MatchBeam" do
  end

  test "Check that if the information received is not with the correct ref, it should notify the error, discard the info and expect another try" do
  end
end
