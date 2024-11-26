defmodule BumblebeeWeb.Schema do
  @moduledoc """
  Contains all of the GraphQL definitions.
  """
  use Absinthe.Schema

  alias BumblebeeWeb.Resolvers

  import_types(BumblebeeWeb.Schema.Types)

  query do
    @desc "Sign in an user"
    field :sign_in, :token do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&Resolvers.User.sign_in/3)
    end

    @desc "List all streams owned by the user"
    field :list_my_streams, list_of(:stream) do
      resolve(&Resolvers.Stream.list_my_streams/3)
    end

    @desc "List all streams which are public and live"
    field :list_streams, list_of(:public_stream) do
      resolve(&Resolvers.Stream.list_streams/3)
    end
  end

  mutation do
    @desc "Create a live stream"
    field :create_stream, type: :stream do
      arg(:title, non_null(:string))
      arg(:description, non_null(:string))

      resolve(&Resolvers.Stream.create_stream/3)
    end

    @desc "End a live stream"
    field :end_my_stream, type: :stream do
      resolve(&Resolvers.Stream.end_my_stream/3)
    end

    @desc "Sign up an user"
    field :sign_up, type: :token do
      arg(:first_name, non_null(:string))
      arg(:last_name, non_null(:string))
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&Resolvers.User.sign_up/3)
    end
  end
end
