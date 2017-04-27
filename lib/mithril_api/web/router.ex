defmodule Mithril.Web.Router do
  @moduledoc """
  The router provides a set of macros for generating routes
  that dispatch to specific controllers and actions.
  Those macros are named after HTTP verbs.

  More info at: https://hexdocs.pm/phoenix/Phoenix.Router.html
  """
  use Mithril.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :put_secure_browser_headers

    # You can allow JSONP requests by uncommenting this line:
    # plug :allow_jsonp
  end

  scope "/oauth", as: :oauth2, alias: Mithril do
    pipe_through :api

    post "/apps/authorize", OAuth.AppController, :authorize
    post "/tokens",         OAuth.TokenController, :create
    get "/tokens/:id",      OAuth.TokenController, :show
  end

  scope "/admin", Mithril.Web do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit] do
      resources "/roles", UserRoleController, except: [:new, :edit, :update], as: :role
    end

    resources "/clients", ClientController, except: [:new, :edit]
    resources "/tokens", TokenController, except: [:new, :edit] do
      get "/verify", TokenController, :verify, as: :verify
    end
    resources "/apps", AppController, except: [:new, :edit]
    resources "/client_types", ClientTypeController, except: [:new, :edit]
    resources "/roles", RoleController, except: [:new, :edit]
  end
end
