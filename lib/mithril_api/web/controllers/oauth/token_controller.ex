defmodule Mithril.OAuth.TokenController do
  use Mithril.Web, :controller

  def create(conn, %{"token" => token_params}) do
    case process(token_params) do
      {:ok, token} ->
        conn
        |> put_status(:created)
        |> render(Mithril.Web.TokenView, "show.json", token: token)
      {:error, {http_status_code, errors}} ->
        # TODO: test rendering errors (code should catch unauthorized.json, etc.)
        conn
        |> render(http_status_code, %{errors: errors})
    end
  end

  defp process(params) do
    case Mithril.Authorization.Token.authorize(params) do
      {:error, errors, http_status_code} ->
        {:error, {http_status_code, errors}}
      {:error, changeset} ->
        {:error, {:unprocessable_entity, changeset}}
      {:ok, token} ->
        {:ok, token}
    end
  end
end
