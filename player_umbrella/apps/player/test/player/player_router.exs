defmodule Player.RouterTest do
  use ExUnit.Case, async: true
  @tag :distributed
  setup_all do
    current = Application.get_env(:player, :routing_table)

    Application.put_env(:player, :routing_table, [
      {?a..?m, :"foo@hakash2002-ThinkPad-E16-Gen-2"},
      {?n..?z, :"bar@hakash2002-ThinkPad-E16-Gen-2"}
    ])

    on_exit(fn -> Application.put_env(:player, :routing_table, current) end)
  end

  @tag :distributed

  test "route requests across nodes" do
    assert Player.Router.route("hello", Kernel, :node, []) ==
             :"foo@hakash2002-ThinkPad-E16-Gen-2"

    assert Player.Router.route("world", Kernel, :node, []) ==
             :"bar@hakash2002-ThinkPad-E16-Gen-2"
  end

  test "raises on unknown entries" do
    assert_raise RuntimeError, ~r/could not find entry/, fn ->
      Player.Router.route(<<0>>, Kernel, :node, [])
    end
  end
end
