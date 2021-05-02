use Mix.Config

config :apms,
  ecto_repos: [Apms.Repo]

config :apms, ApmsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "uJSmHt0ZyJnFY/5ZWQAZtwY4kHYERNzZrRAPjPyLL/Tiz/UZrRpcJtYahKG6pc73",
  render_errors: [view: ApmsWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Apms.PubSub,
  live_view: [signing_salt: "psdmfR82"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :apms, AuthMe.UserManager.Guardian,
  issuer: "apms",
  secret_key: "7cD2Z3/8JOXm/mn5LrvD+36ttI//+JlFFuo0LStylrXHKDo3AGcwxAuOzS2935kq"

import_config "#{Mix.env()}.exs"
