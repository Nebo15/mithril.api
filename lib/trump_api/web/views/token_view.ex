defmodule Trump.Web.TokenView do
  @moduledoc false

  use Trump.Web, :view
  alias Trump.Web.TokenView

  def render("index.json", %{tokens: tokens}) do
    render_many(tokens, TokenView, "token.json")
  end

  def render("show.json", %{token: token}) do
    render_one(token, TokenView, "token.json")
  end

  def render("token.json", %{token: token}) do
    %{id: token.id,
      name: token.name,
      value: token.value,
      expires_at: token.expires_at,
      details: token.details}
  end
end
