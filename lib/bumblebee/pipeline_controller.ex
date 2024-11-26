defmodule Bumblebee.PipelineController do
  @moduledoc """
  Manage and control pipeline processes.
  """
  use GenServer

  alias Bumblebee.Accounts.Stream
  alias Bumblebee.Repo

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:list}, _from, keys) do
    {:reply, keys, keys}
  end

  @impl true
  def handle_call({:lookup, stream_key}, _from, keys) do
    {:reply, Map.fetch(keys, stream_key), keys}
  end

  def handle_call({:delete, stream_key}, _from, keys) do
    keys
    |> Map.fetch(stream_key)
    |> case do
      {:ok, %{client_ref: client_ref}} ->
        send(client_ref, {:disconnect, "live", stream_key})

        {:reply, nil, Map.delete(keys, stream_key)}

      :error ->
        {:reply, nil, keys}
    end
  end

  @impl true
  def handle_cast({:update, stream_key, client_ref, supervisor_pid, pipeline_pid}, keys) do
    keys
    |> Map.fetch(stream_key)
    |> case do
      {:ok, properties} ->
        properties |> Map.values() |> Enum.each(fn value -> Process.exit(value, :kill) end)

        {:noreply,
         Map.put(keys, stream_key, %{
           client_ref: client_ref,
           supervisor_pid: supervisor_pid,
           pipeline_pid: pipeline_pid
         })}

      :error ->
        {:noreply, keys}
    end
  end

  @impl true
  def handle_cast({:create, stream_key, client_ref, supervisor_pid, pipeline_pid}, keys) do
    keys
    |> Map.fetch(stream_key)
    |> case do
      {:ok, _value} ->
        {:noreply, keys}

      :error ->
        {:noreply,
         Map.put(keys, stream_key, %{
           client_ref: client_ref,
           supervisor_pid: supervisor_pid,
           pipeline_pid: pipeline_pid
         })}
    end
  end

  def handle_new_client(client_ref, "live", stream_key) do
    Stream
    |> Repo.get_by(%{key: stream_key})
    |> case do
      %Stream{is_live: true, user_id: user_id} ->
        __MODULE__
        |> GenServer.call({:lookup, stream_key})
        |> case do
          {:ok, %{supervisor_pid: _supervisor_pid, pipeline_pid: _pipeline_pid}} ->
            {:ok, supervisor_pid, pipeline_pid} =
              Membrane.Pipeline.start_link(Bumblebee.Pipeline,
                client_ref: client_ref,
                stream_key: stream_key,
                user_id: user_id
              )

            GenServer.cast(
              __MODULE__,
              {:update, stream_key, client_ref, supervisor_pid, pipeline_pid}
            )

          :error ->
            {:ok, supervisor_pid, pipeline_pid} =
              Membrane.Pipeline.start_link(Bumblebee.Pipeline,
                client_ref: client_ref,
                stream_key: stream_key,
                user_id: user_id
              )

            GenServer.cast(
              __MODULE__,
              {:create, stream_key, client_ref, supervisor_pid, pipeline_pid}
            )
        end

      _error ->
        :error
    end
  end

  def handle_new_client(client_ref, app, stream_key) do
    send(client_ref, {:disconnect, app, stream_key})
  end
end
