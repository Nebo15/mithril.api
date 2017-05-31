defmodule Mithril.Authorization.GrantType.AuthorizationCode do
  @moduledoc false

  alias Mithril.Authorization.GrantType.Error, as: GrantTypeError

  def authorize(%{
      "client_id" => client_id,
      "client_secret" => client_secret,
      "code" => code,
      "redirect_uri" => redirect_uri,
      "scope" => scopes}) do
    client = Mithril.ClientAPI.get_client_by(id: client_id, secret: client_secret)
    do_authorize(client, code, redirect_uri, scopes)
  end
  def authorize(_) do
    message = "Request must include at least client_id, client_secret, code, scopes and redirect_uri parameters."
    GrantTypeError.invalid_request(message)
  end

  defp do_authorize(nil, _, _, _),
    do: GrantTypeError.invalid_client("Invalid client id or secret.")
  defp do_authorize(client, code, redirect_uri, scopes) do
    token = Mithril.TokenAPI.get_token_by(value: code, name: "authorization_code")
    create_token(token, client, redirect_uri, scopes)
  end

  defp create_token(nil, _, _, _), do: GrantTypeError.invalid_grant("Token not found.")
  defp create_token(token, client, redirect_uri, required_scopes) do
    {:ok, token}
    |> validate_client_match(client)
    |> validate_token_expiration
    |> validate_token_redirect_uri(redirect_uri)
    |> validate_app_authorization
    |> validate_requested_scopes(required_scopes)
    |> validate_token_is_not_used()
    |> mark_token_as_used()
    |> create_access_token(required_scopes)
  end

  defp create_access_token({:error, err, code}, _required_scopes), do: {:error, err, code}
  defp create_access_token({:ok, token}, required_scopes) do
    {:ok, refresh_token} = Mithril.TokenAPI.create_refresh_token(%{
      user_id: token.user_id,
      details: %{
        grant_type: "authorization_code",
        client_id: token.details["client_id"],
        scope: required_scopes
      }
    })

    Mithril.TokenAPI.create_access_token(%{
      user_id: token.user_id,
      details: %{
        grant_type: "authorization_code",
        client_id: token.details["client_id"],
        scope: required_scopes,
        refresh_token: refresh_token.value,
        redirect_uri: token.details["redirect_uri"]
      }
    })
  end

  defp mark_token_as_used({:error, err, code}), do: {:error, err, code}
  defp mark_token_as_used({:ok, token}) do
    Mithril.TokenAPI.update_token(token, %{details: Map.put_new(token.details, :used, true)})
  end

  defp validate_app_authorization({:error, err, code}),
    do: {:error, err, code}
  defp validate_app_authorization({:ok, token}) do
    if app = Mithril.AppAPI.approval(token.user_id, token.details["client_id"]) do
      {:ok, token, app}
    else
      GrantTypeError.access_denied("Resource owner revoked access for the client.")
    end
  end

  # TODO: Probably no need to do this at all. When client exchanges code for token,
  # client doesn't have to pass scopes once again.
  #
  # Also, probably no need to pass redirect_uri once again
  defp validate_requested_scopes({:error, err, code}, _), do: {:error, err, code}
  defp validate_requested_scopes({:ok, token, app}, required_scopes) do
    scopes = Mithril.Utils.String.comma_split(app.scope)
    required_scopes = Mithril.Utils.String.comma_split(required_scopes)
    if Mithril.Utils.List.subset?(scopes, required_scopes) do
      {:ok, token}
    else
      GrantTypeError.invalid_scope(scopes)
    end
  end

  defp validate_token_is_not_used({:error, err, code}), do: {:error, err, code}
  defp validate_token_is_not_used({:ok, token}) do
    not_used = !Map.get(token.details, "used", false)

    if not_used do
      {:ok, token}
    else
      GrantTypeError.access_denied("Token has already been used.")
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
    if Mithril.TokenAPI.expired?(token) do
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
end
