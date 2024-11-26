defmodule BumblebeeWeb.Schema.Types do
  @moduledoc """
  Cluster of schema types
  """

  use Absinthe.Schema.Notation

  alias BumblebeeWeb.Schema.Types.{
    PublicStream,
    Stream,
    Token,
    User
  }

  import_types(PublicStream)
  import_types(Stream)
  import_types(User)
  import_types(Token)
end
