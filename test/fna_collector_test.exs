Code.require_file("test_util.exs", __DIR__)

defmodule FnaCollectorTest do
  use ExUnit.Case
  doctest Fna.Application

  setup do
    on_exit fn -> :meck.unload() end
    :ok
  end

  test "Access the providers and send data to database" do
    :meck.new(Fna.DbServer)
    :meck.new(Fna.Util)
    :meck.expect( Fna.DbServer, :send_matches, fn(_, _) -> :ok end )
    :meck.expect( Fna.DbServer, :subscribe_on_timeout, fn() -> :ok end )
    :meck.expect( Fna.DbServer, :update_database, fn(ref, _) -> ref end )
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

    {:ok, _pid} = Fna.MatchBeamSup.start_link([])
    {:ok, _pid} = Fna.FastBallSup.start_link([])
    {:ok, _pid} = Fna.CollectProducer.start_link([])
    assert :ok == wait_db_receive_data(TestUtil.default_providers, TestUtil.default_timeout)
    assert 1 == :meck.num_calls(Fna.DbServer, :subscribe_on_timeout, [])
    assert 1 == :meck.num_calls(Fna.DbServer, :update_database, [:_,:_])
  end

  test "Check that Collectos can crash and restore" do
    :meck.new(Fna.DbServer)
    :meck.new(Fna.Util)
    :meck.expect( Fna.DbServer, :send_matches, fn(_, _) -> :ok end )
    :meck.expect( Fna.DbServer, :subscribe_on_timeout, fn() -> :ok end )
    :meck.expect( Fna.DbServer, :update_database, fn(ref, _) -> ref end )
    :meck.expect( Fna.Util,:create_match, &(
      %{ server_name: &1,
         home_team: &2,
         away_team: &3,
         kickoff_at: &4,
         created_at: &5
      }))
    :meck.expect( Fna.Util,:capture_data, fn(url) ->
      matchbeam_url = TestUtil.matchbeam_url
      called = :persistent_term.get(:test, 0)
      case {called, url} do
       {n, _} when n <=4  -> :persistent_term.put(:test, n + 1)
                             Process.exit(self(), :kill)
       {_,^matchbeam_url} ->
          {:ok, TestUtil.matchbeam_sample_match}
       {_,_} ->
            {:ok,  TestUtil.fastball_sample_match}
      end
    end )

    {:ok, _pid} = Fna.MatchBeamSup.start_link([])
    {:ok, _pid} = Fna.FastBallSup.start_link([])
    {:ok, _pid} = Fna.CollectProducer.start_link([])
    assert :ok == wait_db_receive_data(TestUtil.default_providers, TestUtil.default_timeout)
    assert 1 == :meck.num_calls(Fna.DbServer, :subscribe_on_timeout, [])
    assert 1 == :meck.num_calls(Fna.DbServer, :update_database, [:_,:_])
  end

  test "Check timeout from database receiving messages" do
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
      called = :persistent_term.get(:test, 0)
      case {called, url} do
       {n, _} when n <= 2  -> :persistent_term.put(:test, n + 1)
                              :timer.sleep 500 # force timeout
                              Process.exit(self(), :kill)
       {_,^matchbeam_url} ->
          {:ok, TestUtil.matchbeam_sample_match}
       {_,_} ->
            {:ok,  TestUtil.fastball_sample_match}
      end
    end )

    {:ok, _pid} = Fna.DbServer.start_link([], 100)
    {:ok, _pid} = Fna.MatchBeamSup.start_link([])
    {:ok, _pid} = Fna.FastBallSup.start_link([])
    {:ok, _pid} = Fna.CollectProducer.start_link([])
    assert :ok == wait_persist(4, TestUtil.default_timeout)
  end

  test "Invalid data received from providers" do
    :meck.new(Fna.DbServer)
    :meck.new(Fna.Util)
    :meck.expect( Fna.DbServer, :send_matches, fn(_, _) -> :ok end )
    :meck.expect( Fna.DbServer, :subscribe_on_timeout, fn() -> :ok end )
    :meck.expect( Fna.DbServer, :update_database, fn(ref, _) -> ref end )
    :meck.expect( Fna.Util,:create_match, &(
      %{ server_name: &1,
         home_team: &2,
         away_team: &3,
         kickoff_at: &4,
         created_at: &5
      }))
    :meck.expect( Fna.Util,:capture_data, fn(url) ->
      matchbeam_url = TestUtil.matchbeam_url
      called = Process.get(:test, 0)
      case {called, url} do
       {n, _} when n < 1  -> Process.put(:test, n + 1)
          {:error, TestUtil.matchbeam_sample_match}
       {_,^matchbeam_url} ->
          {:ok, TestUtil.matchbeam_sample_match}
       {_,_} ->
            {:ok,  TestUtil.fastball_sample_match}
      end
    end )

    {:ok, _pid} = Fna.MatchBeamSup.start_link([])
    {:ok, _pid} = Fna.FastBallSup.start_link([])
    {:ok, _pid} = Fna.CollectProducer.start_link([])
    assert :ok == wait_access_provider(4, TestUtil.default_timeout)
    assert :ok == wait_db_receive_data(2, TestUtil.default_timeout)
    assert 1 == :meck.num_calls(Fna.DbServer, :subscribe_on_timeout, [])
    assert 1 == :meck.num_calls(Fna.DbServer, :update_database, [:_,:_])
  end

  def wait_db_receive_data(_, 0), do: :error
  def wait_db_receive_data(n_messages, timeout) do
    case :meck.num_calls(Fna.DbServer, :send_matches, [:_,:_]) do
      ^n_messages -> :ok
      _           -> :timer.sleep 1
                     wait_db_receive_data(n_messages, timeout - 1)
    end
  end

  def wait_access_provider(_, 0), do: :error
  def wait_access_provider(n_messages, timeout) do
    case :meck.num_calls(Fna.Util, :capture_data, [:_]) do
      n when n >= n_messages -> :ok
      _ -> :timer.sleep 1
            wait_access_provider(n_messages, timeout - 1)
    end
  end

  def wait_persist(n_messages, timeout) do
    case :meck.num_calls(Fna.Util, :persist, [:_]) do
      n when n >= n_messages -> :ok
      _ -> :timer.sleep 1
           wait_persist(n_messages, timeout - 1)
    end
  end
end
