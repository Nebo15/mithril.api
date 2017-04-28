defmodule Mithril.OAuth.AppController do
  use Mithril.Web, :controller

  plug Authable.Plug.Authenticate, [scopes: ~w(app:authorize)] when action in [:authorize]

  # POST /apps/authorize
  def authorize(conn, %{"app" => app_params}) do
    params = Map.put(app_params, "user", conn.assigns[:current_user])

    case process(params) do
      {:ok, %{"token" => token}} ->
        conn
        |> put_status(:created)
        |> render(Mithril.Web.TokenView, "show.json", token: token)
      {:error, {http_status_code, errors}} ->
        conn
        |> render(http_status_code, %{errors: errors})
    end
  end

  defp process(%{"user" => user} = params) do
    case Authable.OAuth2.grant_app_authorization(user, params) do
      {:error, errors, http_status_code} ->
        {:error, {http_status_code, errors}}
      {:error, changeset} ->
        {:error, {:unprocessable_entity, changeset}}
      res ->
        {:ok, res}
    end
  end
end
