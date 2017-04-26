defmodule Mithril.Web.ClientTypeView do
  use Mithril.Web, :view
  alias Mithril.Web.ClientTypeView

  def render("index.json", %{client_types: client_types}) do
    render_many(client_types, ClientTypeView, "client_type.json")
  end

  def render("show.json", %{client_type: client_type}) do
    render_one(client_type, ClientTypeView, "client_type.json")
  end

  def render("client_type.json", %{client_type: client_type}) do
    %{id: client_type.id,
      name: client_type.name,
      scope: client_type.scope}
  end
end
