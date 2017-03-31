defmodule Trump.Web.UserView do
  use Trump.Web, :view
  alias Trump.Web.UserView

  def render("index.json", %{users: users}) do
    render_many(users, UserView, "user.json")
  end

  def render("show.json", %{user: user}) do
    render_one(user, UserView, "user.json")
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      email: user.email,
      password: user.password,
      scopes: user.scopes}
  end
end
