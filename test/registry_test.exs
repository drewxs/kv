defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    registry = start_supervised!(KV.Registry, [])
    %{registry: registry}
  end

  test "spawn buckets", %{registry: registry} do
    assert KV.Registry.lookup(registry, "item") == :error

    KV.Registry.create(registry, "item")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "item")

    KV.Bucket.put(bucket, "item", 1)
    assert KV.Bucket.get(bucket, "item") == 1
  end

  test "removes bucket on exit", %{registry: registry} do
    KV.Registry.create(registry, "item")
    {:ok, bucket} = KV.Registry.lookup(registry, "item")
    Agent.stop(bucket)
    assert KV.Registry.lookup(registry, "item") == :error
  end
end
