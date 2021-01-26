defmodule Fna.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :server_name, :string
      add :home_team,   :string
      add :away_team,   :string

      add :kickoff_at, :timestamp
      add :created_at, :timestamp
    end

    create unique_index(:matches, [:server_name, :home_team, :away_team, :kickoff_at])
  end
end
