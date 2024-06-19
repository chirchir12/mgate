defmodule Mgate.Repo do
  use Ecto.Repo,
    otp_app: :mgate,
    adapter: Ecto.Adapters.Postgres
end
