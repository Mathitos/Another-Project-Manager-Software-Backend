use Mix.Config

config :apms, ApmsWeb.Endpoint,
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

# https: [
#   port: 443,
#   cipher_suite: :strong,
#   keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#   certfile: System.get_env("SOME_APP_SSL_CERT_PATH"),
#   transport_options: [socket_opts: [:inet6]]
# ]

config :logger, level: :info

import_config "prod.secret.exs"
