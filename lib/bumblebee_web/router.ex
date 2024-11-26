defmodule BumblebeeWeb.Router do
  use BumblebeeWeb, :router

  pipeline :graphql do
    plug Plug.Parsers,
      parsers: [:urlencoded, :multipart, :json],
      pass: ["*/*"],
      json_decoder: Poison

    plug BumblebeeWeb.Middleware.Context
  end

  scope "/api" do
    pipe_through :graphql

    forward "/graphql", Absinthe.Plug, schema: BumblebeeWeb.Schema

    if Mix.env() == :dev do
      forward "/graphiql", Absinthe.Plug.GraphiQL,
        schema: BumblebeeWeb.Schema,
        interface: :advanced
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:bumblebee, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: BumblebeeWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
