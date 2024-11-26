defmodule Bumblebee.Repo do
  use Ecto.Repo,
    otp_app: :bumblebee,
    adapter: Ecto.Adapters.Postgres
end
