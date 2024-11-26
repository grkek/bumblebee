defmodule Bumblebee.Repo.Migrations.CreateStreams do
  use Ecto.Migration

  def change do
    create table(:streams, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :key, :string

      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:streams, [:key])
  end
end
