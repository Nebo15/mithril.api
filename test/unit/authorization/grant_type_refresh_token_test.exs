defmodule Mithril.Authorization.GrantType.RefreshTokenTest do
  use Mithril.DataCase, async: true

  alias Mithril.Authorization.GrantType.RefreshToken, as: RefreshTokenGrantType

  test "creates refresh-granted access token" do
    client = Mithril.Fixtures.create_client()
    user   = Mithril.Fixtures.create_user()

    Mithril.AppAPI.create_app(%{
      user_id: user.id,
      client_id: client.id,
      scope: "legal_entity:read legal_entity:write"
    })

    {:ok, refresh_token} = Mithril.Fixtures.create_refresh_token(client, user)

    {:ok, token} = RefreshTokenGrantType.authorize(%{
      "client_id" => client.id,
      "client_secret" => client.secret,
      "refresh_token" => refresh_token.value
    })

    assert token.name == "access_token"
    assert token.value
    assert token.expires_at
    assert token.user_id == user.id
    assert token.details.client_id == client.id
    assert token.details.grant_type == "refresh_token"
    assert token.details.scope == "legal_entity:read legal_entity:write"
  end

  test "it returns Request must include at least... error" do
    {:error, errors, code} = RefreshTokenGrantType.authorize(%{})

    message = "Request must include at least client_id, client_secret and refresh_token parameters."
    assert %{invalid_request: ^message} = errors
    assert :bad_request == code
  end

  test "it returns invalid client id or secret error" do
    client = Mithril.Fixtures.create_client()

    {:error, errors, code} = RefreshTokenGrantType.authorize(%{
      "client_id" => "F75029D0-DDBA-4897-A6F2-9A785222FD67",
      "client_secret" => client.secret,
      "refresh_token" => "some_value"
    })

    assert %{invalid_client: "Invalid client id or secret."} = errors
    assert :unauthorized = code
  end

  test "it returns Token Not Found error" do
    client = Mithril.Fixtures.create_client()

    {:error, errors, code} = RefreshTokenGrantType.authorize(%{
      "client_id" => client.id,
      "client_secret" => client.secret,
      "refresh_token" => "some_token"
    })

    assert %{invalid_grant: "Token not found."} = errors
    assert :unauthorized = code
  end

  test "it returns Resource owner revoked access for the client error" do
    client = Mithril.Fixtures.create_client()
    user   = Mithril.Fixtures.create_user()

    {:ok, refresh_token} = Mithril.Fixtures.create_refresh_token(client, user)

    {:error, errors, code} = RefreshTokenGrantType.authorize(%{
      "client_id" => client.id,
      "client_secret" => client.secret,
      "refresh_token" => refresh_token.value
    })

    assert %{access_denied: "Resource owner revoked access for the client."} = errors
    assert :unauthorized = code
  end

  test "it returns token expired error" do
    client = Mithril.Fixtures.create_client()
    user   = Mithril.Fixtures.create_user()

    Mithril.AppAPI.create_app(%{
      user_id: user.id,
      client_id: client.id,
      scope: "legal_entity:read legal_entity:write"
    })

    {:ok, refresh_token} = Mithril.Fixtures.create_refresh_token(client, user, 0)

    {:error, errors, code} = RefreshTokenGrantType.authorize(%{
      "client_id" => client.id,
      "client_secret" => client.secret,
      "refresh_token" => refresh_token.value
    })

    assert %{invalid_grant: "Token expired."} = errors
    assert :unauthorized = code
  end

  test "it returns token not found or expired error" do
    client = Mithril.Fixtures.create_client()
    user   = Mithril.Fixtures.create_user()

    Mithril.AppAPI.create_app(%{
      user_id: user.id,
      client_id: client.id,
      scope: "legal_entity:read legal_entity:write"
    })

    client2 = Mithril.Fixtures.create_client(%{name: "Another name"})
    {:ok, refresh_token} = Mithril.Fixtures.create_refresh_token(client2, user)

    {:error, errors, code} = RefreshTokenGrantType.authorize(%{
      "client_id" => client.id,
      "client_secret" => client.secret,
      "refresh_token" => refresh_token.value
    })

    assert %{invalid_grant: "Token not found or expired."} = errors
    assert :unauthorized = code
  end
end
