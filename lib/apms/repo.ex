defmodule Apms.Repo do
  use Ecto.Repo,
    otp_app: :apms,
    adapter: Ecto.Adapters.Postgres
end
