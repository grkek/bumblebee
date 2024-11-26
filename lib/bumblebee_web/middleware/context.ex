defmodule BumblebeeWeb.Middleware.Context do
  @moduledoc false
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, claims} <- Bumblebee.Guardian.decode_and_verify(token),
         {:ok, user} <- Bumblebee.Guardian.resource_from_claims(claims) do
      Absinthe.Plug.put_options(conn, context: %{current_user: user})
    else
      _error ->
        Absinthe.Plug.put_options(conn, context: %{current_user: nil})
    end
  end
end
