defmodule Mithril.Authorization.App do
  @moduledoc false

  @scopes Application.get_env(:mithril_api, :scopes)

  # NOTE: On every approval a new token is created.
  # Current (session) token with it's scopes is still valid until it expires.
  # E.g. session expiration should be sufficiently short
  #
  # TODO:
  # After find_client() call, issue a establish_scopes_to_be_granted() call
  # in order to "clash" 3 things: client_type, user_role and scopes being requested
  def grant(%{"user_id" => _, "client_id" => _, "redirect_uri" => _, "scope" => _} = params) do
    params
    |> find_user()
    |> find_client()
    |> update_or_create_app()
    |> create_token()
  end
  def grant(_) do
    message = "Request must include at least client_id, redirect_uri and scopes parameters."
    {:error, %{invalid_client: message}, :bad_request}
  end

  defp find_client(%{"client_id" => client_id, "redirect_uri" => redirect_uri} = params) do
    case Mithril.ClientAPI.get_client_by([id: client_id, redirect_uri: redirect_uri]) do
      nil ->
        {:error, %{invalid_client: "Client not found"}, :unprocessable_entity}
      client ->
        Map.put(params, "client", client)
    end
  end

  defp find_user(%{"user_id" => user_id} = params) do
    case Mithril.Web.UserAPI.get_user(user_id) do
      nil ->
        {:error, %{invalid_client: "User not found"}, :unprocessable_entity}
      user ->
        Map.put(params, "user", user)
    end
  end

  defp update_or_create_app({:error, errors, status}) do
    {:error, errors, status}
  end
  defp update_or_create_app(%{"user" => user, "client_id" => client_id, "scope" => scope} = params) do
    app =
      case Mithril.AppAPI.get_app_by([user_id: user.id, client_id: client_id]) do
        nil ->
          {:ok, app} = Mithril.AppAPI.create_app(%{user_id: user.id, client_id: client_id, scope: scope})

          app
        app ->
          update_app_scopes({app, scope})
      end
    Map.put(params, "app", app)
  end

  defp update_app_scopes({app, scope}) do
    if app.scope != scope do
      scope =
        scope
        |> Mithril.Utils.String.comma_split
        |> Enum.concat(Mithril.Utils.String.comma_split(app.scope))
        |> Enum.uniq()
      scope = @scopes -- (@scopes -- scope)
      Mithril.AppAPI.update_app(app, %{scope: Enum.join(scope, ",")})
    else
      app
    end
  end

  defp create_token({:error, errors, status}) do
    {:error, errors, status}
  end

  defp create_token(%{"user" => user, "client" => client} = params) do
    {:ok, token} = Mithril.TokenAPI.create_authorization_code(%{
      user_id: user.id,
      details: %{
        client_id: client.id,
        grant_type: "password",
        redirect_uri: client.redirect_uri,
        scope: "app:authorize"
      }
    })

    Map.put(params, "token", token)
  end
end
