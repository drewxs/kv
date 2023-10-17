import Config

config :kv, :routing_table, [{?a..?z, node()}]

if config_env() == :prod do
  config :kv, :routing_table, [
    {?a..?m, :foo@drew},
    {?n..?z, :bar@drew}
  ]
end

config :iex, default_prompt: ">>>"
