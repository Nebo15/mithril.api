defmodule Mithril.Web.Endpoint do
  @moduledoc """
  Phoenix Endpoint for mithril_api application.
  """
  use Phoenix.Endpoint, otp_app: :mithril_api

  # Allow acceptance tests to run in concurrent mode
  if Application.get_env(:mithril_api, :sql_sandbox) do
    plug Phoenix.Ecto.SQL.Sandbox
  end

  plug Plug.RequestId
  plug EView.Plugs.Idempotency
  plug Plug.Logger

  plug EView

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_trump_key",
    signing_salt: "signing_salt"

  plug Mithril.Web.Router

  @doc """
  Dynamically loads configuration from the system environment
  on startup.

  It receives the endpoint configuration from the config files
  and must return the updated configuration.
  """
  def load_from_system_env(config) do
    config = Confex.process_env(config)

    unless config[:secret_key_base] do
      raise "Set SECRET_KEY environment variable!"
    end

    {:ok, config}
  end
end
