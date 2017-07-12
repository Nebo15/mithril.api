defmodule Mithril.Web.TokenController do
  use Mithril.Web, :controller

  alias Mithril.TokenAPI
  alias Mithril.TokenAPI.Token

  action_fallback Mithril.Web.FallbackController

  def index(conn, params) do
    with {tokens, %Ecto.Paging{} = paging} <- TokenAPI.list_tokens(params) do
      render(conn, "index.json", tokens: tokens, paging: paging)
    end
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
    case TokenAPI.verify(value) do
      {:ok, token} ->
        render(conn, "show.json", token: token)
      {:error, errors, http_status_code} ->
        conn
        |> put_status(http_status_code)
        |> render(Mithril.Web.TokenView, http_status_code, errors: errors)
    end
  end

  def user(conn, %{"token_id" => value}) do
    case TokenAPI.verify(value) do
      {:ok, token} ->
        user = Mithril.UserAPI.get_full_user(token.user_id, token.details["client_id"])

        render(conn, Mithril.Web.UserView, "urgent.json", user: user, urgent: true, expires_at: token.expires_at)
      {:error, errors, http_status_code} ->
        conn
        |> put_status(http_status_code)
        |> render(Mithril.Web.TokenView, http_status_code, errors: errors)
    end
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

  def delete_by_user(conn, %{"user_id" => user_id}) do
    with {_, nil} <- TokenAPI.delete_tokens_by_user(user_id) do
      send_resp(conn, :no_content, "")
    end
  end
end
