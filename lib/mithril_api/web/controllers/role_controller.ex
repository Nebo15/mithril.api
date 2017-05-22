defmodule Mithril.Web.RoleController do
  use Mithril.Web, :controller

  alias Mithril.RoleAPI
  alias Mithril.RoleAPI.Role

  action_fallback Mithril.Web.FallbackController

  def index(conn, params) do
    with {roles, %Ecto.Paging{} = paging} <- RoleAPI.list_roles(params) do
      render(conn, "index.json", roles: roles, paging: paging)
    end
  end

  def create(conn, %{"role" => role_params}) do
    with {:ok, %Role{} = role} <- RoleAPI.create_role(role_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", role_path(conn, :show, role))
      |> render("show.json", role: role)
    end
  end

  def show(conn, %{"id" => id}) do
    role = RoleAPI.get_role!(id)
    render(conn, "show.json", role: role)
  end

  def update(conn, %{"id" => id, "role" => role_params}) do
    role = RoleAPI.get_role!(id)

    with {:ok, %Role{} = role} <- RoleAPI.update_role(role, role_params) do
      render(conn, "show.json", role: role)
    end
  end

  def delete(conn, %{"id" => id}) do
    role = RoleAPI.get_role!(id)
    with {:ok, %Role{}} <- RoleAPI.delete_role(role) do
      send_resp(conn, :no_content, "")
    end
  end
end
