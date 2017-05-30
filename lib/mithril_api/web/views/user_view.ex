defmodule Mithril.Web.UserView do
  @moduledoc false

  use Mithril.Web, :view
  alias Mithril.Web.UserView

  def render("index.json", %{users: users}) do
    render_many(users, UserView, "user.json")
  end

  def render("show.json", %{user: user}) do
    render_one(user, UserView, "user.json")
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      email: user.email,
      settings: user.settings}
  end

  def render("urgent.json", %{user: user, urgent: true, expiration: expiration}) do
    %{
      id: user.id,
      email: user.email,
      settings: user.settings,
      urgent: %{
        roles: render_many(user.roles, Mithril.Web.RoleView, "show.json"),
        expiration: expiration
      }
    }
  end
end
