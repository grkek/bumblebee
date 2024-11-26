defmodule BumblebeeWeb.Schema.Types.User do
  @moduledoc false
  use Absinthe.Schema.Notation

  object :user do
    field :id, :id
    field :first_name, :string
    field :last_name, :string
    field :email, :string
  end
end
