defmodule Mithril.Authorization.GrantType.AuthorizationCode do
  @moduledoc false

  alias Mithril.Authorization.GrantType.Error, as: GrantTypeError

  def authorize(%{
      "client_id" => client_id,
      "client_secret" => client_secret,
      "code" => code,
      "redirect_uri" => redirect_uri}) do
    client = Mithril.ClientAPI.get_client_by(id: client_id, secret: client_secret)
    do_authorize(client, code, redirect_uri)
  end
  def authorize(_) do
    message = "Request must include at least client_id, client_secret, code, scopes and redirect_uri parameters."
    GrantTypeError.invalid_request(message)
  end

  defp do_authorize(nil, _, _),
    do: GrantTypeError.invalid_client("Invalid client id or secret.")
  defp do_authorize(client, code, redirect_uri) do
    token = Mithril.TokenAPI.get_token_by(value: code, name: "authorization_code")
    create_token(token, client, redirect_uri)
  end

  defp create_token(nil, _, _), do: GrantTypeError.invalid_grant("Token not found.")
  defp create_token(token, client, redirect_uri) do
    {:ok, token}
    |> validate_client_match(client)
    |> validate_token_expiration
    |> validate_token_redirect_uri(redirect_uri)
    |> validate_app_authorization()
    |> validate_token_is_not_used()
    |> mark_token_as_used()
    |> create_access_token()
  end

  defp create_access_token({:error, err, code}), do: {:error, err, code}
  defp create_access_token({:ok, token, _app}) do
    {:ok, refresh_token} = Mithril.TokenAPI.create_refresh_token(%{
      user_id: token.user_id,
      details: %{
        grant_type: "authorization_code",
        client_id: token.details["client_id"],
        scope: token.details["scope"]
      }
    })

    Mithril.TokenAPI.create_access_token(%{
      user_id: token.user_id,
      details: %{
        grant_type: "authorization_code",
        client_id: token.details["client_id"],
        scope: token.details["scope"],
        refresh_token: refresh_token.value,
        redirect_uri: token.details["redirect_uri"]
      }
    })
  end

  defp mark_token_as_used({:error, err, code}), do: {:error, err, code}
  defp mark_token_as_used({:ok, token, app}) do
    {:ok, token} = Mithril.TokenAPI.update_token(token, %{details: Map.put_new(token.details, :used, true)})
    {:ok, token, app}
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

  defp validate_token_is_not_used({:error, err, code}), do: {:error, err, code}
  defp validate_token_is_not_used({:ok, token, app}) do
    not_used = !Map.get(token.details, "used", false)

    if not_used do
      {:ok, token, app}
    else
      GrantTypeError.access_denied("Token has already been used.")
    end
  end

  defp validate_token_redirect_uri({:error, err, code}, _),
    do: {:error, err, code}
  defp validate_token_redirect_uri({:ok, token}, redirect_uri) do
    if String.starts_with?(redirect_uri, token.details["redirect_uri"]) do
      {:ok, token}
    else
      GrantTypeError.invalid_client("The redirection URI provided does not match a pre-registered value.")
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
