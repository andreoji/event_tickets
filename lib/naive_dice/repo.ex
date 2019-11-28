defmodule NaiveDice.Repo do
  use Ecto.Repo,
    otp_app: :naive_dice,
    adapter: Ecto.Adapters.Postgres
end
