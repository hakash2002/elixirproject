defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = Player.Bucket.start_link(%{})
    %{bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert Player.Bucket.get(bucket, "Chase") == nil

    Player.Bucket.put(bucket, "Chase", [power: 90, speed: 90, agility: 90])
    assert Player.Bucket.get(bucket, "Chase") == [power: 90, speed: 90, agility: 90]
  end
end
