defmodule Bumblebee.Pipeline do
  @moduledoc """
  Handle incomming stream, extract audio and write it as an HLS data to AWS S3.
  """
  use Membrane.Pipeline

  def start_link(opts) do
    Membrane.Pipeline.start_link(__MODULE__, opts, name: Bumblebee.Pipeline)
  end

  @impl true
  def handle_init(_context, client_ref: client_ref, stream_key: stream_key, user_id: user_id) do
    source = %Membrane.RTMP.SourceBin{client_ref: client_ref}

    structure =
      [
        # Process and save the audio stream to a CDN.
        child(:source, source)
        |> via_out(:audio)
        |> via_in(Pad.ref(:input, :audio),
          options: [encoding: :AAC, segment_duration: Membrane.Time.seconds(4), track_name: "index"]
        )
        |> child(:audio_sink, %Membrane.HTTPAdaptiveStream.SinkBin{
          manifest_module: Membrane.HTTPAdaptiveStream.HLS,
          target_window_duration: :infinity,
          persist?: false,
          mode: :live,
          storage: %Bumblebee.Storages.S3Storage{stream_key: stream_key, user_id: user_id}
        }),
        # Ignore the video stream.
        get_child(:source)
        |> via_out(:video)
        |> child(:video_sink, Membrane.Fake.Sink.Buffers)
      ]

    {[spec: structure], %{}}
  end

  # The rest of the module is used for self-termination of the pipeline after processing finishes
  @impl true
  def handle_element_end_of_stream(:sink, _pad, _ctx, state) do
    {[terminate: :normal], state}
  end

  @impl true
  def handle_element_end_of_stream(_child, _pad, _ctx, state) do
    {[], state}
  end
end
