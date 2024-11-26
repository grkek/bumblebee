defmodule BumblebeeWeb.Schema.Types.Token do
  @moduledoc false
  use Absinthe.Schema.Notation

  object :token do
    field :value, :string
  end
end
