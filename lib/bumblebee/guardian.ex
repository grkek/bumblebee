defmodule Bumblebee.Guardian do
  @moduledoc """
  Guardian module which is used to authorize the JWT tokens
  """
  use Guardian, otp_app: :bumblebee

  alias Bumblebee.Accounts.User
  alias Bumblebee.Repo

  def subject_for_token(%User{} = user, _claims) do
    {:ok, to_string(user.id)}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(%{"sub" => id}) do
    User
    |> Repo.get(id)
    |> case do
      nil ->
        {:error, :resource_not_found}

      user ->
        {:ok, user}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
