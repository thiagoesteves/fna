Code.require_file("test_util.exs", __DIR__)

defmodule FnaAppTest do
  use ExUnit.Case
  doctest Fna.Application

  @app_name :fna_app

  setup do
    :meck.new(Fna.Util)
    :meck.expect( Fna.Util,:persist, fn(_) -> :inserted end )
    :meck.expect( Fna.Util,:create_match, &(
      %{ server_name: &1,
         home_team: &2,
         away_team: &3,
         kickoff_at: &4,
         created_at: &5
      }))
    :meck.expect( Fna.Util,:capture_data, fn(url) ->
      matchbeam_url = TestUtil.matchbeam_url
      case url do
       ^matchbeam_url ->
          {:ok, TestUtil.matchbeam_sample_match}
       _ ->
            {:ok,  TestUtil.fastball_sample_match}
      end
    end )

    :ok = Application.start(@app_name)
    on_exit fn -> Application.stop(@app_name)
                  :meck.unload() end
    :ok
  end

  test "check Application is running" do
    assert nil != Process.whereis(Fna.Supervisor)
  end

  test "check Application is already started" do
    assert {:error, {:already_started, _}} = Fna.Application.start(:none, :none)
  end
end
