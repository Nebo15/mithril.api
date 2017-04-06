defmodule Trump.Web.ClientView do
  use Trump.Web, :view
  alias Trump.Web.ClientView

  def render("index.json", %{clients: clients}) do
    render_many(clients, ClientView, "client.json")
  end

  def render("show.json", %{client: client}) do
    render_one(client, ClientView, "client.json")
  end

  def render("client.json", %{client: client}) do
    %{id: client.id,
      name: client.name,
      secret: client.secret,
      redirect_uri: client.redirect_uri,
      settings: client.settings,
      priv_settings: client.priv_settings}
  end
end
