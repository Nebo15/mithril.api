defmodule Trump.Web.AppView do
  use Trump.Web, :view
  alias Trump.Web.AppView

  def render("index.json", %{apps: apps}) do
    render_many(apps, AppView, "app.json")
  end

  def render("show.json", %{app: app}) do
    render_one(app, AppView, "app.json")
  end

  def render("app.json", %{app: app}) do
    %{id: app.id,
      scope: app.scope}
  end
end
