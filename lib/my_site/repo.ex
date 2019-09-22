defmodule MySite.Repo do
  use Ecto.Repo,
    otp_app: :my_site,
    adapter: Ecto.Adapters.Postgres
end
