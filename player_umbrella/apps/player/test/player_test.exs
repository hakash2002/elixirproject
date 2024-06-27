defmodule PlayerTest do
  use ExUnit.Case, async: true
  use Agent

  setup context do
    _ = start_supervised!({Player.Api, name: context.test})
    %{registry: context.test}
  end

  test "spawns buckets", %{registry: registry} do
    assert Player.Api.get(registry, "Offense") == :error

    Player.Api.create(registry, "Offense")
    assert {:ok, bucket} = Player.Api.get(registry, "Offense")

    Player.Api.put(registry,"Offense", "Chase", 90, 90, 90)
    assert Player.Api.get(registry, "Offense","Chase") == [power: 90, speed: 90, agility: 90]

    Player.Bucket.put(bucket, "Chase", [power: 90, speed: 90, agility: 90])
    assert Player.Bucket.get(bucket, "Chase") == [power: 90, speed: 90, agility: 90]

    Player.Api.delete(registry,"Offense")
    assert Player.Api.get(registry, "Offense") == :error

    Player.Api.delete(registry,"Offense", "Chase")
    assert Player.Api.get(registry, "Offense","Chase") == :error

  end

  test "removes buckets on exit", %{registry: registry} do
    Player.Api.create(registry, "Offense", "Travis kelce", 90, 90, 90)
    {:ok, bucket} = Player.Api.get(registry, "Offense")
    Agent.stop(bucket)

    _ = Player.Api.create(registry, "bogus", "bogus", nil, nil, nil)
    assert Player.Api.get(registry, "Offense") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    Player.Api.create(registry, "Offense", "Travis kelce", 90, 90, 90)
    {:ok, bucket} = Player.Api.get(registry, "Offense")

    Agent.stop(bucket, :shutdown)

    _ = Player.Api.create(registry, "bogus", "bogus", nil, nil, nil)
    assert Player.Api.get(registry, "Offense") == :error
  end

  test "are temporary workers" do
    assert Supervisor.child_spec(Player.Bucket, %{}).restart == :temporary
  end
end
