defmodule Mithril.OAuth.TokenController do
  use Mithril.Web, :controller

  # TODO: this will be on Gateway - remove all such calls
  # plug Authable.Plug.Authenticate, [scopes: ~w(session read write)] when action in [:authorize, :delete]

  # POST /tokens
  def create(conn, %{"token" => token_params}) do
    case process(token_params) do
      {:ok, token} ->
        conn
        |> put_status(:created)
        |> render(Mithril.Web.TokenView, "show.json", token: token)
      {:error, {http_status_code, errors} = res} ->
        conn
        |> render(http_status_code, %{errors: errors})
    end
  end

  def show(conn, %{"id" => _, "client_id" => _, "client_secret" => _} = params) do
    case Mithril.TokenApi.TokenSearch.find(params) do
      {:ok, %{"token" => token}} ->
        conn
        |> put_status(:ok)
        |> render(Mithril.Web.TokenView, "show.json", token: token)
      {:error, {http_status_code, errors}} ->
        conn
        |> render(http_status_code, %{errors: errors})
    end
  end

  defp process(params) do
    case Authable.OAuth2.authorize(params) do
      {:error, errors, http_status_code} ->
        {:error, {http_status_code, errors}}
      {:error, changeset} ->
        {:error, {:unprocessable_entity, changeset}}
      token ->
        {:ok, token}
    end
  end
end
