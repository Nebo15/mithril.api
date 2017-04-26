defmodule Mithril.Web.RoleView do
  use Mithril.Web, :view
  alias Mithril.Web.RoleView

  def render("index.json", %{roles: roles}) do
    render_many(roles, RoleView, "role.json")
  end

  def render("show.json", %{role: role}) do
    render_one(role, RoleView, "role.json")
  end

  def render("role.json", %{role: role}) do
    %{id: role.id,
      name: role.name,
      scope: role.scope}
  end
end
