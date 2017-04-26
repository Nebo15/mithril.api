defmodule Mithril.Web.UserRoleView do
  use Mithril.Web, :view
  alias Mithril.Web.UserRoleView

  def render("index.json", %{user_roles: user_roles}) do
    render_many(user_roles, UserRoleView, "user_role.json")
  end

  def render("show.json", %{user_role: user_role}) do
    render_one(user_role, UserRoleView, "user_role.json")
  end

  def render("user_role.json", %{user_role: user_role}) do
    %{id: user_role.id,
      user_id: user_role.user_id,
      role_id: user_role.role_id,
      client_id: user_role.client_id}
  end
end
