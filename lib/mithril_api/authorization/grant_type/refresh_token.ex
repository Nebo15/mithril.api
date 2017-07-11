defmodule Mithril.Authorization.GrantType.RefreshToken do
  @moduledoc false

  alias Mithril.Authorization.GrantType.Error, as: GrantTypeError

  def authorize(%{"client_id" => client_id, "client_secret" => client_secret, "refresh_token" => token}) do
    {client_id, client_secret, token}
    |> load_client
    |> load_token
    |> validate_client_match
    |> validate_token_expiration
    |> validate_app_authorization
    |> create_access_token
  end
  def authorize(_) do
    message = "Request must include at least client_id, client_secret and refresh_token parameters."
    GrantTypeError.invalid_request(message)
  end

  defp load_client({client_id, client_secret, token}) do
    case Mithril.ClientAPI.get_client_by(id: client_id, secret: client_secret) do
      nil ->
        GrantTypeError.invalid_client("Invalid client id or secret.")
      client ->
        {:ok, client, token}
    end
  end

  defp load_token({:error, _, _} = error), do: error
  defp load_token({:ok, client, value}) do
    case Mithril.TokenAPI.get_token_by(value: value, name: "refresh_token") do
      nil ->
        GrantTypeError.invalid_grant("Token not found.")
      token ->
        {:ok, client, token}
    end
  end

  defp validate_client_match({:error, _, _} = error), do: error
  defp validate_client_match({:ok, client, token}) do
    case token.details["client_id"] == client.id do
      true ->
        {:ok, client, token}
      _ ->
        GrantTypeError.invalid_grant("Token not found or expired.")
    end
  end

  defp validate_token_expiration({:error, _, _} = error), do: error
  defp validate_token_expiration({:ok, client, token}) do
    if Mithril.TokenAPI.expired?(token) do
      GrantTypeError.invalid_grant("Token expired.")
    else
      {:ok, client, token}
    end
  end

  defp validate_app_authorization({:error, _, _} = error), do: error
  defp validate_app_authorization({:ok, client, token}) do
    case Mithril.AppAPI.approval(token.user_id, token.details["client_id"]) do
      nil ->
        GrantTypeError.access_denied("Resource owner revoked access for the client.")
      app ->
        {:ok, client, token, app}
    end
  end

  defp create_access_token({:error, _, _} = error), do: error
  defp create_access_token({:ok, client, token, _app}) do
    Mithril.TokenAPI.create_access_token(%{
      user_id: token.user_id,
      details: %{
        grant_type: "refresh_token",
        client_id: client.id,
        scope: token.details["scope"]
      }
    })
  end
end
