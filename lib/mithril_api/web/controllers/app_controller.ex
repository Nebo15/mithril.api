defmodule Mithril.Web.AppController do
  use Mithril.Web, :controller

  alias Mithril.AppAPI
  alias Mithril.AppAPI.App

  action_fallback Mithril.Web.FallbackController

  def index(conn, params) do
    with {apps, %Ecto.Paging{} = paging} <- AppAPI.list_apps(params) do
      render(conn, "index.json", apps: apps, paging: paging)
    end
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

  def delete_by_user(conn, %{"user_id" => user_id}) do
    with {_, nil} <- AppAPI.delete_apps_by_user(user_id) do
      send_resp(conn, :no_content, "")
    end
  end
end
