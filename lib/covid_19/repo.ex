defmodule Covid19.Repo do
  use Ecto.Repo,
    otp_app: :covid_19,
    adapter: Ecto.Adapters.Postgres
end
