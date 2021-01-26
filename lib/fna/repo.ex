defmodule Fna.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :fna_app,
    adapter: Ecto.Adapters.Postgres
end
