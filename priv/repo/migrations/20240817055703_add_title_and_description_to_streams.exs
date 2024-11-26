defmodule Bumblebee.Repo.Migrations.AddTitleAndDescriptionToStreams do
  use Ecto.Migration

  def change do
    alter table(:streams) do
      add :title, :string
      add :description, :string
    end
  end
end
