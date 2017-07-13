defmodule Mithril.Authorization.App do
  @moduledoc false

  # NOTE: Mark password token as used.
  #
  # On every approval a new token is created.
  # Current (session) token with it's scopes is still valid until it expires.
  # E.g. session expiration should be sufficiently short.
  def grant(%{"user_id" => _, "client_id" => _, "redirect_uri" => _, "scope" => _} = params) do
    params
    |> find_client()
    |> find_user()
    |> validate_redirect_uri()
    |> validate_client_scope()
    |> validate_user_scope()
    |> update_or_create_app()
    |> create_token()
  end
  def grant(_) do
    message = "Request must include at least client_id, redirect_uri and scopes parameters."
    {:error, %{invalid_client: message}, :bad_request}
  end

  defp find_client(%{"client_id" => client_id} = params) do
    case Mithril.ClientAPI.get_client_with_type(client_id) do
      nil -> {:error, %{invalid_client: "Client not found"}, :unprocessable_entity}
      client -> Map.put(params, "client", client)
    end
  end

  defp find_user({:error, errors, status}), do: {:error, errors, status}
  defp find_user(%{"user_id" => user_id, "client" => %{id: client_id}} = params) do
    case Mithril.UserAPI.get_full_user(user_id, client_id) do
      nil -> {:error, %{invalid_client: "User not found"}, :unprocessable_entity}
      user -> Map.put(params, "user", user)
    end
  end

  defp validate_redirect_uri({:error, errors, status}), do: {:error, errors, status}
  defp validate_redirect_uri(%{"client" => client, "redirect_uri" => redirect_uri} = params) do
    if String.starts_with?(redirect_uri, client.redirect_uri) do
      params
    else
      message = "The redirection URI provided does not match a pre-registered value."
      {:error, %{invalid_client: message}, :unprocessable_entity}
    end
  end

  defp validate_client_scope({:error, errors, status}), do: {:error, errors, status}
  defp validate_client_scope(%{"client" => %{client_type: %{scope: client_type_scope}}, "scope" => scope} = params) do
    allowed_scopes = String.split(client_type_scope, " ", trim: true)
    requested_scopes = String.split(scope, " ", trim: true)
    if Mithril.Utils.List.subset?(allowed_scopes, requested_scopes) do
      params
    else
      message = "Scope is not allowed by client type."
      {:error, %{invalid_client: message}, :unprocessable_entity}
    end
  end

  defp validate_user_scope({:error, errors, status}), do: {:error, errors, status}
  defp validate_user_scope(%{"user" => %{roles: user_roles}, "scope" => scope} = params) do
    allowed_scopes = user_roles |> Enum.map_join(" ", &(&1.scope)) |> String.split(" ", trim: true)
    requested_scopes = String.split(scope, " ", trim: true)
    if Mithril.Utils.List.subset?(allowed_scopes, requested_scopes) do
      params
    else
      message = "User requested scope that is not allowed by role based access policies."
      {:error, %{invalid_client: message}, :unprocessable_entity}
    end
  end

  defp update_or_create_app({:error, errors, status}), do: {:error, errors, status}
  defp update_or_create_app(%{"user" => user, "client_id" => client_id, "scope" => scope} = params) do
    app =
      case Mithril.AppAPI.get_app_by([user_id: user.id, client_id: client_id]) do
        nil ->
          {:ok, app} = Mithril.AppAPI.create_app(%{user_id: user.id, client_id: client_id, scope: scope})

          app
        app ->
          aggregated_scopes = String.split(scope, " ", trim: true) ++ String.split(app.scope, " ", trim: true)
          aggregated_scope = aggregated_scopes |> Enum.uniq() |> Enum.join(" ")

          Mithril.AppAPI.update_app(app, %{scope: aggregated_scope})
      end

    Map.put(params, "app", app)
  end

  defp create_token({:error, errors, status}), do: {:error, errors, status}
  defp create_token(%{"user" => user, "client" => client, "redirect_uri" => redirect_uri, "scope" => scope} = params) do
    {:ok, token} =
      Mithril.TokenAPI.create_authorization_code(%{
        user_id: user.id,
        details: %{
          client_id: client.id,
          grant_type: "password",
          redirect_uri: redirect_uri,
          scope: scope
        }
      })

    Map.put(params, "token", token)
  end
end
