defmodule Mithril.Authorization.GrantType.AuthorizationCode do
  @moduledoc false

  alias Mithril.Authorization.GrantType.Error, as: GrantTypeError

  def authorize(%{"client_id" => client_id, "client_secret" => client_secret, "code" => code, "redirect_uri" => redirect_uri, "scope" => scopes}) do
    client = Mithril.ClientAPI.get_client_by(id: client_id, secret: client_secret)
    do_authorize(client, code, redirect_uri, scopes)
  end
  def authorize(_) do
    GrantTypeError.invalid_request("Request must include at least client_id, client_secret, code, scopes and redirect_uri parameters.")
  end

  defp do_authorize(nil, _, _, _),
    do: GrantTypeError.invalid_client("Invalid client id or secret.")
  defp do_authorize(client, code, redirect_uri, scopes) do
    token = Mithril.TokenAPI.get_token_by(value: code, name: "authorization_code")
    create_token(token, client, redirect_uri, scopes)
  end

  defp create_token(nil, _, _, _), do: {:error, %{invalid_token: "Token not found."}, :unauthorized}
  defp create_token(token, client, redirect_uri, required_scopes) do
    {:ok, token}
    |> validate_client_match(client)
    |> validate_token_expiration
    |> validate_token_redirect_uri(redirect_uri)
    |> validate_app_authorization
    |> validate_requested_scopes(required_scopes)
    |> delete_code_grant_token
    |> create_access_token(required_scopes)
  end

  defp create_access_token({:error, err, code}, _required_scopes), do: {:error, err, code}
  defp create_access_token({:ok, token}, required_scopes) do
    Mithril.TokenAPI.create_access_token(%{
      user_id: token.user_id,
      details: %{
        grant_type: "authorization_code",
        client_id: token.details["client_id"],
        scope: required_scopes,
        redirect_uri: token.details["redirect_uri"]
      }
    })
  end

  defp delete_code_grant_token({:error, err, code}), do: {:error, err, code}
  defp delete_code_grant_token({:ok, token, _app}), do: Mithril.TokenAPI.delete_token(token)

  defp validate_app_authorization({:error, err, code}),
    do: {:error, err, code}
  defp validate_app_authorization({:ok, token}) do
    if app = get_app(token.user_id, token.details["client_id"]) do
      {:ok, token, app}
    else
      GrantTypeError.access_denied("Resource owner revoked access for the client.")
    end
  end

  defp validate_requested_scopes({:error, err, code}, _), do: {:error, err, code}
  defp validate_requested_scopes({:ok, token, app}, required_scopes) do
    scopes = Authable.Utils.String.comma_split(app.scope)
    required_scopes = Authable.Utils.String.comma_split(required_scopes)
    if Authable.Utils.List.subset?(scopes, required_scopes) do
      {:ok, token, app}
    else
      GrantTypeError.invalid_scope(scopes)
    end
  end

  defp validate_token_redirect_uri({:error, err, code}, _),
    do: {:error, err, code}
  defp validate_token_redirect_uri({:ok, token}, redirect_uri) do
    if token.details["redirect_uri"] != redirect_uri do
      GrantTypeError.invalid_client("The redirection URI provided does not match a pre-registered value.")
    else
      {:ok, token}
    end
  end

  defp validate_token_expiration({:error, err, code}),
    do: {:error, err, code}
  defp validate_token_expiration({:ok, token}) do
    if Mithril.TokenAPI.is_expired?(token) do
      GrantTypeError.invalid_grant("Token expired.")
    else
      {:ok, token}
    end
  end

  defp validate_client_match({:ok, token}, client) do
    if token.details["client_id"] != client.id do
      GrantTypeError.invalid_grant("Token not found or expired.")
    else
      {:ok, token}
    end
  end

  defp get_app(user_id, client_id) do
    Mithril.AppAPI.get_app_by(user_id: user_id, client_id: client_id)
  end
end
