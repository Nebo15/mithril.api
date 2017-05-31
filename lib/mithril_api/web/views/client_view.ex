defmodule Mithril.Web.ClientView do
  use Mithril.Web, :view
  alias Mithril.Web.ClientView

  def render("index.json", %{clients: clients, render_secret: render_secret}) do
    render_many(clients, ClientView, "client.json", render_secret: render_secret)
  end

  def render("show.json", %{client: client, render_secret: render_secret}) do
    render_one(client, ClientView, "client.json", render_secret: render_secret)
  end

  def render("client.json", %{client: client, render_secret: render_secret}) do
    response = %{
      id: client.id,
      name: client.name,
      redirect_uri: client.redirect_uri,
      settings: client.settings,
      priv_settings: client.priv_settings
    }

    if render_secret do
      Map.put_new(response, :secret, client.secret)
    else
      response
    end
  end
end
