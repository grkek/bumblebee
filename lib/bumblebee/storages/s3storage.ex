defmodule Bumblebee.Storages.S3Storage do
  @moduledoc """
  `Membrane.HTTPAdaptiveStream.Storage` implementation that saves the stream to
  files on AWS S3.
  """
  @behaviour Membrane.HTTPAdaptiveStream.Storage

  alias ExAws.S3

  require Logger

  @enforce_keys [:stream_key, :user_id]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
          stream_key: String.t(),
          user_id: String.t()
        }

  @impl true
  def init(%__MODULE__{} = config), do: config

  @impl true
  def store(
        _parent_id,
        _name,
        _contents,
        _metadata,
        %{mode: :binary, type: :partial_segment},
        state
      ) do
    Logger.warning("File storage does not support LL-HLS. The partial segment is omitted.")
    {:ok, state}
  end

  @impl true
  def store(
        _parent_id,
        name,
        contents,
        _metadata,
        %{mode: :binary},
        %{stream_key: stream_key, user_id: user_id} = state
      ) do
    stream_key
    |> unique_key_hash_pair(user_id)
    |> process_and_upload_file(name, contents, :text)
    |> case do
      :ok ->
        {:ok, state}

      {:error, error} ->
        {:error, error}
    end
  end

  @impl true
  def store(
        _parent_id,
        name,
        contents,
        _metadata,
        %{mode: :text},
        %{stream_key: stream_key, user_id: user_id} = state
      ) do
    stream_key
    |> unique_key_hash_pair(user_id)
    |> process_and_upload_file(name, contents, :text)
    |> case do
      :ok ->
        {:ok, state}

      {:error, error} ->
        {:error, error}
    end
  end

  @impl true
  def remove(
        _parent_id,
        _name,
        _ctx,
        %__MODULE__{stream_key: _stream_key, user_id: _user_id} = state
      ) do
    {:ok, state}
  end

  def process_and_upload_file(key, name, contents, mode) do
    directory_path = Path.join("/tmp", key)

    unless File.exists?(directory_path), do: File.mkdir(directory_path)

    file_path = Path.join(directory_path, name)

    case mode do
      :text ->
        File.write!(file_path, contents)

      :binary ->
        File.write!(file_path, contents, [:binary])
    end

    file_path
    |> upload_file_to_s3(key, name)
    |> case do
      :ok ->
        File.rm(file_path)

      {:error, error} ->
        {:error, error}
    end
  end

  defp upload_file_to_s3(path, key, name) do
    bucket = System.fetch_env!("AWS_S3_BUCKET_NAME")

    path
    |> S3.Upload.stream_file()
    |> S3.upload(bucket, Path.join(key, name), acl: :public_read)
    |> ExAws.request()
    |> case do
      {:ok, _result} ->
        :ok

      {:error, error} ->
        {:error, error}
    end
  end

  def unique_key_hash_pair(stream_key, user_id) do
    :sha
    |> :crypto.hash(stream_key <> user_id)
    |> Base.encode16()
    |> String.downcase()
  end
end
