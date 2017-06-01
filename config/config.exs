# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :mithril_api, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:mithril_api, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#
# Or read environment variables in runtime (!) as:
#
#     :var_name, "${ENV_VAR_NAME}"

config :mithril_api,
  ecto_repos: [Mithril.Repo],
  namespace: Mithril

# Configure your database
config :mithril_api, Mithril.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: {:system, "DB_NAME", "mithril_api_dev"},
  username: {:system, "DB_USER", "postgres"},
  password: {:system, "DB_PASSWORD", "postgres"},
  hostname: {:system, "DB_HOST", "localhost"},
  port: {:system, :integer, "DB_PORT", 5432}

config :mithril_api, :generators,
  migration: false,
  binary_id: true,
  sample_binary_id: "11111111-1111-1111-1111-111111111111"

# Configures the endpoint
config :mithril_api, Mithril.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "6sOsW9uKv+8o8y/hIA3F4dNkJE2O35e2l6SaS9P/xW0+Nh9Fo59T6JHnl0GzBmio",
  render_errors: [view: EView.Views.PhoenixError, accepts: ~w(json)]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure JSON Logger back-end
config :logger_json, :backend,
  on_init: {Mithril, :load_from_system_env, []},
  json_encoder: Poison,
  metadata: :all

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#

import_config "#{Mix.env}.exs"

config :mithril_api, :scopes, ~w(
  app:authorize
  legal_entity:read
  legal_entity:write
  employee_request:write
  employee_request:reject
  employee_request:read
  employee_request:approve
  employee:write
  employee:read
  dictionary:read
  address:read
)

config :mithril_api, :token_lifetime, %{
  code: {:system, "AUTH_CODE_GRANT_LIFETIME", 5 * 60},
  access: {:system, "AUTH_ACCESS_TOKEN_LIFETIME", 30 * 24 * 60 * 60},
  refresh: {:system, "AUTH_REFRESH_TOKEN_LIFETIME", 7 * 24 * 60 * 60}
}
