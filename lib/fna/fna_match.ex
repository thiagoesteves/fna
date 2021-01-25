defmodule Fna.Match do
  @moduledoc false
  use Ecto.Schema

  schema "matches" do
    field :server_name, :string
    field :home_team,   :string
    field :away_team,   :string
    field :kickoff_at,  :utc_datetime
    field :created_at,  :utc_datetime
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:id, :server_name, :home_team, :away_team, :kickoff_at, :created_at])
    |> Ecto.Changeset.validate_required([:server_name, :home_team, :away_team, :kickoff_at, :created_at])
  end

end