defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    _ = start_supervised!({KV.Registry, name: context.test})
    %{registry: context.test}
  end

  test "spawn buckets", %{registry: registry} do
    assert KV.Registry.lookup(registry, "reg") == :error

    KV.Registry.create(registry, "reg")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "reg")

    KV.Bucket.put(bucket, "item", 1)
    assert KV.Bucket.get(bucket, "item") == 1
  end

  test "removes bucket on exit", %{registry: registry} do
    KV.Registry.create(registry, "item")
    {:ok, bucket} = KV.Registry.lookup(registry, "item")
    Agent.stop(bucket)

    _ = KV.Registry.create(registry, "nil")
    assert KV.Registry.lookup(registry, "item") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    KV.Registry.create(registry, "reg")
    {:ok, bucket} = KV.Registry.lookup(registry, "reg")
    Agent.stop(bucket, :shutdown)

    _ = KV.Registry.create(registry, "nil")
    assert KV.Registry.lookup(registry, "reg") == :error
  end

  test "bucket can crash at any time", %{registry: registry} do
    KV.Registry.create(registry, "reg")
    {:ok, bucket} = KV.Registry.lookup(registry, "reg")
    Agent.stop(bucket, :shutdown)

    catch_exit(KV.Bucket.put(bucket, "item", 3))
  end
end
