defmodule Bumblebee.Accounts.Stream do
  @moduledoc """
  Stream schema.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Bumblebee.Accounts.User

  @primary_key {:id, UUIDv7, autogenerate: true}
  schema "streams" do
    field :key, :string
    field :title, :string
    field :description, :string
    field :is_live, :boolean, default: false

    belongs_to :user, User, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(stream, attrs) do
    stream
    |> cast(attrs, [:key, :is_live, :title, :description, :user_id])
    |> unique_constraint(:key)
    |> validate_required([:key, :title, :description])
  end
end
