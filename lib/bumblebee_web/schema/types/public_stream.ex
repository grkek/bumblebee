defmodule BumblebeeWeb.Schema.Types.PublicStream do
  @moduledoc false
  use Absinthe.Schema.Notation

  object :public_stream do
    field :id, :id
    field :title, :string
    field :description, :string
    field :access_token, :string
  end
end
