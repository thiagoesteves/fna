Code.require_file("test_util.exs", __DIR__)

defmodule FnaDbTest do
  use ExUnit.Case
  doctest Fna.Application

  @ref_test 12345648151455

  setup do
    on_exit fn -> :meck.unload() end
    :ok
  end

  def wait_db_notification(timeout) do
    receive do
      :db_timeout -> :ok
    after
      timeout -> :error
    end
  end

  test "Create more than on isntance of Fna.DbServer" do
    {:ok, _pid} = Fna.DbServer.start_link([])
    assert {:error, {:already_started, _}} = Fna.DbServer.start_link([])
  end

  test "Test update_database method against the state" do
    :meck.new(Fna.Util)
    :meck.expect( Fna.Util,:persist, fn(_) -> :inserted end )

    {:ok, pid} = Fna.DbServer.start_link([])
    @ref_test = Fna.DbServer.update_database(@ref_test, TestUtil.default_providers)
    assert %{n_messages: 2, ref: @ref_test} = :sys.get_state(pid)
  end

  test "Send Matches and check they were processed" do
    :meck.new(Fna.Util)
    :meck.expect( Fna.Util,:persist, fn(_) -> :inserted end )

    {:ok, pid} = Fna.DbServer.start_link([])
    @ref_test = Fna.DbServer.update_database(@ref_test, TestUtil.default_providers)
    :ok= Fna.DbServer.send_matches(@ref_test, [:none])
    assert %{n_messages: 1, ref: @ref_test} = :sys.get_state(pid)
    :ok= Fna.DbServer.send_matches(@ref_test, [:none])
    assert %{n_messages: 0, ref: :undefined} = :sys.get_state(pid)

    assert TestUtil.default_providers == :meck.num_calls(Fna.Util, :persist, [:_])
  end

  test "Check Timeout notification" do
    {:ok, _pid} = Fna.DbServer.start_link([], 100)
    :new = Fna.DbServer.subscribe_on_timeout()
    @ref_test = Fna.DbServer.update_database(@ref_test, TestUtil.default_providers)
    assert wait_db_notification(1000) == :ok
  end

  test "Check invalid reference error" do
    {:ok, _pid} = Fna.DbServer.start_link([], 200)
    :new = Fna.DbServer.subscribe_on_timeout()
    @ref_test = Fna.DbServer.update_database(@ref_test, TestUtil.default_providers)
    :ok= Fna.DbServer.send_matches(0, [:none])
    :ok= Fna.DbServer.send_matches(0, [:none])
    assert wait_db_notification(1000) == :ok
  end

  test "Check no messages expected" do
    {:ok, _pid} = Fna.DbServer.start_link([], 200)
    :ok = Fna.DbServer.send_matches(0, [:none])
    :ok = Fna.DbServer.send_matches(0, [:none])
    :timer.sleep(100)
  end
end
