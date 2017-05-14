defmodule Mithril.OAuth.AppController do
  use Mithril.Web, :controller

  # TODO: Must be protected by gateway? E.g. incoming request must have "can make approvals" scope

  # POST /apps/authorize
  def authorize(conn, %{"app" => app_params}) do
    [user_id | _] = Plug.Conn.get_req_header(conn, "x-consumer-id")
    params = Map.put(app_params, "user_id", user_id)

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

  defp process(params) do
    # Double check what it does:
    # Authable.OAuth2.grant_app_authorization(user, params) do
    case Mithril.Authorization.App.grant(params) do
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
