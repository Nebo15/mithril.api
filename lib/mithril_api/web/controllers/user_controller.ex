defmodule Mithril.Web.UserController do
  @moduledoc false

  use Mithril.Web, :controller

  alias Mithril.Web.UserAPI
  alias Mithril.Web.UserAPI.User

  action_fallback Mithril.Web.FallbackController

  def index(conn, params) do
    with {users, %Ecto.Paging{} = paging} <- UserAPI.list_users(params) do
      render(conn, "index.json", users: users, paging: paging)
    end
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- UserAPI.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = UserAPI.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = UserAPI.get_user!(id)

    with {:ok, %User{} = user} <- UserAPI.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = UserAPI.get_user!(id)
    with {:ok, %User{}} <- UserAPI.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
