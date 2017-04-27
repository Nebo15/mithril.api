defmodule Mithril.Web.TokenController do
  use Mithril.Web, :controller

  alias Mithril.TokenAPI
  alias Mithril.TokenAPI.Token

  action_fallback Mithril.Web.FallbackController

  def index(conn, _params) do
    tokens = TokenAPI.list_tokens()
    render(conn, "index.json", tokens: tokens)
  end

  def create(conn, %{"token" => token_params}) do
    with {:ok, %Token{} = token} <- TokenAPI.create_token(token_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", token_path(conn, :show, token))
      |> render("show.json", token: token)
    end
  end

  def show(conn, %{"id" => id}) do
    token = TokenAPI.get_token!(id)
    render(conn, "show.json", token: token)
  end

  def verify(conn, %{"token_id" => value}) do
    token = TokenAPI.get_token_by_value!(value)
    render(conn, "show.json", token: token)
  end

  def update(conn, %{"id" => id, "token" => token_params}) do
    token = TokenAPI.get_token!(id)

    with {:ok, %Token{} = token} <- TokenAPI.update_token(token, token_params) do
      render(conn, "show.json", token: token)
    end
  end

  def delete(conn, %{"id" => id}) do
    token = TokenAPI.get_token!(id)
    with {:ok, %Token{}} <- TokenAPI.delete_token(token) do
      send_resp(conn, :no_content, "")
    end
  end
end
