defmodule HTTPizza.Repo do
  use Ecto.Repo,
    otp_app: :httpizza,
    adapter: Ecto.Adapters.Postgres
end
