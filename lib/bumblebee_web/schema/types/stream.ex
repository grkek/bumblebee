defmodule BumblebeeWeb.Schema.Types.Stream do
  @moduledoc false
  use Absinthe.Schema.Notation

  object :stream do
    field :id, :id
    field :title, :string
    field :description, :string
    field :is_live, :boolean
    field :key, :string
    field :access_token, :string
  end
end
