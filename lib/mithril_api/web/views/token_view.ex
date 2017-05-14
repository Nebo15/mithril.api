defmodule Mithril.Web.TokenView do
  @moduledoc false

  use Mithril.Web, :view
  alias Mithril.Web.TokenView

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
      user_id: token.user_id,
      details: token.details}
  end

  def render("unprocessable_entity.json", errors), do: errors
  def render("unauthorized.json", errors), do: errors
  def render("bad_request.json", errors), do: errors
end
