defmodule Mithril.OAuth.TokenController do
  use Mithril.Web, :controller

  def create(conn, %{"token" => token_params}) do
    case process(token_params) do
      {:ok, token} ->
        conn
        |> put_status(:created)
        |> render(Mithril.Web.TokenView, "show.json", token: token)
      {:error, {http_status_code, errors}} ->
        conn
        |> render(http_status_code, %{errors: errors})
    end
  end

  defp process(params) do
    case Mithril.OAuth2.authorize(params) do
      {:error, errors, http_status_code} ->
        {:error, {http_status_code, errors}}
      {:error, changeset} ->
        {:error, {:unprocessable_entity, changeset}}
      token ->
        {:ok, token}
    end
  end
end
