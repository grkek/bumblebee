defmodule Bumblebee.Repo.Migrations.AddIsLiveToStreams do
  use Ecto.Migration

  def change do
    alter table(:streams) do
      add :is_live, :boolean, default: false
    end
  end
end
