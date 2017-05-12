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
        |> put_resp_header("location", generate_location(token))
        |> render(Mithril.Web.TokenView, "show.json", token: token)
      {:error, {http_status_code, errors}} ->
        conn
        |> render(http_status_code, %{errors: errors})
    end
  end

  defp process(%{"user" => user} = params) do
    # TODO:
    #   use Mithril.Authorization.App.grant(params)
    #
    # params must have:
    #
    #   @app_authorization.grant(%{"user" => user, "client_id" => client_id,
    #   "redirect_uri" => redirect_uri, "scope" => scope})
    case Authable.OAuth2.grant_app_authorization(user, params) do
      {:error, errors, http_status_code} ->
        {:error, {http_status_code, errors}}
      {:error, changeset} ->
        {:error, {:unprocessable_entity, changeset}}
      res ->
        {:ok, res}
    end
  end

  defp generate_location(token) do
    redirect_uri = URI.parse(token.details.redirect_uri)

    new_redirect_uri =
      Map.update! redirect_uri, :query, fn(query) ->
        query =
          if query, do: URI.decode_query(query), else: %{}

        query
        |> Map.merge(%{code: token.value})
        |> URI.encode_query
      end

    URI.to_string(new_redirect_uri)
  end
end
