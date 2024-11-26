defmodule BumblebeeWeb.Resolvers.User do
  @moduledoc """
  User related GraphQL resolver functionality.
  """

  alias Bumblebee.Accounts.User
  alias Bumblebee.Guardian
  alias Bumblebee.Repo

  # TODO: define endpoints where we will use this.
  # def sign_in(_parent, _args, %{context: %{current_user: nil}}),
  #   do: {:error, "You are not authorized to use this resource, please provide a valid token"}

  def sign_in(_parent, %{email: email, password: password}, %{
        context: %{current_user: _current_user}
      }) do
    User
    |> Repo.get_by(%{email: email})
    |> case do
      nil ->
        {:error,
         "Unable to find an user with such an E-Mail address, or the password was incorrect."}

      %{id: id, password_hash: password_hash} = user ->
        password
        |> Bcrypt.verify_pass(password_hash)
        |> case do
          true ->
            expiration = :os.system_time(:seconds) + 86_400

            user
            |> Guardian.encode_and_sign(%{exp: expiration})
            |> case do
              {:ok, value, _claims} ->
                {:ok, %{id: id, value: value, expiration: expiration}}

              _error ->
                {:error, "Something went wrong, please try again later."}
            end

          false ->
            {:error,
             "Unable to find an user with such an E-Mail address, or the password was incorrect."}
        end
    end
  end

  def sign_up(
        _parent,
        %{first_name: _first_name, last_name: _last_name, email: _email, password: _password} =
          attrs,
        _resolution
      ) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, %{id: id} = user} ->
        expiration = :os.system_time(:seconds) + 86_400

        user
        |> Guardian.encode_and_sign(%{exp: expiration})
        |> case do
          {:ok, value, _claims} ->
            {:ok, %{id: id, value: value, expiration: expiration}}

          _error ->
            {:error, "Something went wrong, please try again later."}
        end

      {:error, _error} ->
        {:error, "Something went wrong, please try again later."}
    end
  end
end
