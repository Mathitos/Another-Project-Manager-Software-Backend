use Mix.Config

config :apms, Apms.Repo,
  username: "postgres",
  password: "postgres",
  database: "apms_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :apms, ApmsWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warn
