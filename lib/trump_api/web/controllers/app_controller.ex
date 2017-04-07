defmodule Trump.Web.AppController do
  use Trump.Web, :controller

  alias Trump.AppAPI
  alias Trump.AppAPI.App

  action_fallback Trump.Web.FallbackController

  def index(conn, _params) do
    apps = AppAPI.list_apps()
    render(conn, "index.json", apps: apps)
  end

  def create(conn, %{"app" => app_params}) do
    with {:ok, %App{} = app} <- AppAPI.create_app(app_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", app_path(conn, :show, app))
      |> render("show.json", app: app)
    end
  end

  def show(conn, %{"id" => id}) do
    app = AppAPI.get_app!(id)
    render(conn, "show.json", app: app)
  end

  def update(conn, %{"id" => id, "app" => app_params}) do
    app = AppAPI.get_app!(id)

    with {:ok, %App{} = app} <- AppAPI.update_app(app, app_params) do
      render(conn, "show.json", app: app)
    end
  end

  def delete(conn, %{"id" => id}) do
    app = AppAPI.get_app!(id)
    with {:ok, %App{}} <- AppAPI.delete_app(app) do
      send_resp(conn, :no_content, "")
    end
  end
end
