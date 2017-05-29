defmodule Mithril.Web.AppView do
  use Mithril.Web, :view
  alias Mithril.Web.AppView

  def render("index.json", %{apps: apps}) do
    render_many(apps, AppView, "app.json")
  end

  def render("show.json", %{app: app}) do
    render_one(app, AppView, "app.json")
  end

  def render("app.json", %{app: app}) do
    %{
      id: app.id,
      scope: app.scope,
      user_id: app.user_id,
      client_id: app.client_id
    }
  end
end
