defmodule BumblebeeWeb.Resolvers.Stream do
  @moduledoc """
  Stream related GraphQL resolver functionality.
  """

  import Ecto.Query

  alias Ecto.Changeset
  alias Bumblebee.Accounts.Stream
  alias Bumblebee.Repo

  def list_my_streams(_parent, _args, %{context: %{current_user: nil}}),
    do: {:error, "You are not authorized to use this resource, please provide a valid token."}

  def list_my_streams(_parent, _args, %{context: %{current_user: %{id: id}}}) do
    query = from(s in Stream, where: s.user_id == ^id)

    streams =
      query
      |> Repo.all(user_id: id)
      |> Enum.map(fn %{key: key} = stream ->
        Map.put(stream, :access_token, Bumblebee.Storages.S3Storage.unique_key_hash_pair(key, id))
      end)

    {:ok, streams}
  end

  def list_streams(_parent, _args, %{context: %{current_user: nil}}),
    do: {:error, "You are not authorized to use this resource, please provide a valid token."}

  def list_streams(_parent, _args, %{context: %{current_user: %{id: _id}}}) do
    query = from(s in Stream, where: s.is_live == true)

    streams =
      query
      |> Repo.all()
      |> Enum.map(fn %{key: key, user_id: user_id} = stream ->
        Map.put(
          stream,
          :access_token,
          Bumblebee.Storages.S3Storage.unique_key_hash_pair(key, user_id)
        )
      end)

    {:ok, streams}
  end

  def create_stream(_parent, _args, %{context: %{current_user: nil}}),
    do: {:error, "You are not authorized to use this resource, please provide a valid token."}

  def create_stream(_parent, %{title: title, description: description}, %{
        context: %{current_user: %{id: id}}
      }) do
    key = generate_stream_key()
    query = from(s in Stream, where: s.user_id == ^id)

    query
    |> Repo.all(user_id: id)
    |> Enum.map(fn %{is_live: is_live} ->
      is_live
    end)
    |> Enum.any?()
    |> case do
      true ->
        {:error,
         "You are already in a streaming mode, please end the current stream to begin a new one."}

      false ->
        %Stream{}
        |> Stream.changeset(%{
          title: title,
          description: description,
          key: key,
          user_id: id,
          is_live: true
        })
        |> Repo.insert()
        |> case do
          {:ok, stream} ->
            {:ok,
             Map.put(
               stream,
               :access_token,
               Bumblebee.Storages.S3Storage.unique_key_hash_pair(key, id)
             )}

          {:error, _error} ->
            {:error, "Something went wrong, try again later."}
        end
    end
  end

  def end_my_stream(_parent, _args, %{context: %{current_user: nil}}),
    do: {:error, "You are not authorized to use this resource, please provide a valid token."}

  def end_my_stream(_parent, _args, %{context: %{current_user: %{id: id}}}) do
    query = from(s in Stream, where: s.user_id == ^id and s.is_live == true)

    query
    |> Repo.all()
    |> Enum.map(fn %{key: key} = stream ->
      # Disconnect the client from the RTMP server.
      GenServer.call(Bumblebee.PipelineController, {:delete, key})

      # Update the stream.
      stream
      |> Changeset.change(is_live: false)
      |> Changeset.optimistic_lock(:version)
      |> Repo.update()
    end)
    |> case do
      [result] ->
        result

      [] ->
        {:error, "You are not in a streaming mode."}
    end
  end

  defp generate_stream_key do
    0..3
    |> Enum.map(fn _index ->
      2 |> :crypto.strong_rand_bytes() |> Base.encode16() |> String.downcase()
    end)
    |> Enum.join("-")
  end
end
