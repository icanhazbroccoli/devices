use Mix.Config

config :kafka_ex,
  brokers: [
    {"127.0.0.1", 9092},
  ],
  consumer_group: "kafka_ex",
  sync_timeout: 3000,
  max_restarts: 10,
  max_seconds: 10,
  use_ssl: false,
  kafka_version: "0.10.1"
