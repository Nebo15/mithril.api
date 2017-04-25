defmodule Trump.Web.UserRoleController do
  use Trump.Web, :controller

  alias Trump.Web.UserAPI.User
  alias Trump.UserRoleAPI
  alias Trump.UserRoleAPI.UserRole

  action_fallback Trump.Web.FallbackController

  def index(conn, %{"user_id" => user_id}) do
    user_roles = UserRoleAPI.list_user_roles(user_id)

    render(conn, "index.json", user_roles: user_roles)
  end

  def create(conn, %{"user_id" => user_id, "user_role" => user_role_params}) do
    user_role_attrs = Map.put_new(user_role_params, "user_id", user_id)

    with {:ok, %UserRole{} = user_role} <- UserRoleAPI.create_user_role(user_role_attrs) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_role_path(conn, :show, user_role.user_id, user_role.id))
      |> render("show.json", user_role: user_role)
    end
  end

  def show(conn, %{"id" => id}) do
    user_role = UserRoleAPI.get_user_role!(id)
    render(conn, "show.json", user_role: user_role)
  end

  def delete(conn, %{"id" => id}) do
    user_role = UserRoleAPI.get_user_role!(id)
    with {:ok, %UserRole{}} <- UserRoleAPI.delete_user_role(user_role) do
      send_resp(conn, :no_content, "")
    end
  end
end
