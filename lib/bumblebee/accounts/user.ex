defmodule Bumblebee.Accounts.User do
  @moduledoc """
  User schema.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Bumblebee.Accounts.Stream

  @primary_key {:id, UUIDv7, autogenerate: true}
  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    has_many :streams, Stream

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :password])
    |> unique_constraint(:email)
    |> hash_password()
    |> validate_required([:first_name, :last_name, :email, :password_hash])
  end

  defp hash_password(changeset) do
    hash = Bcrypt.hash_pwd_salt(get_field(changeset, :password))
    put_change(changeset, :password_hash, hash)
  end
end
