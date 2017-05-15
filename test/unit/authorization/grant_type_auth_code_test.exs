defmodule Mithril.Authorization.GrantType.AuthorizationCodeTest do
  use Mithril.DataCase, async: true

  alias Mithril.Authorization.GrantType.AuthorizationCode, as: AuthorizationCodeGrantType

  test "creates code-granted access token" do
    client = Mithril.Fixtures.create_client()
    user   = Mithril.Fixtures.create_user()

    Mithril.AppAPI.create_app(%{
      user_id: user.id,
      client_id: client.id,
      scope: "some_api:read some_api:write"
    })

    {:ok, code_grant} = Mithril.Fixtures.create_code_grant_token(client, user)

    {:ok, token} = AuthorizationCodeGrantType.authorize(%{
      "client_id" => client.id,
      "client_secret" => client.secret,
      "code" => code_grant.value,
      "redirect_uri" => client.redirect_uri,
      "scope" => "some_api:read"
    })

    assert token.name == "access_token"
    assert token.value
    assert token.expires_at
    assert token.user_id == user.id
    assert token.details.client_id == client.id
    assert token.details.refresh_token
    assert token.details.grant_type == "authorization_code"
    assert token.details.redirect_uri == client.redirect_uri
    assert token.details.scope == "some_api:read"
  end

  test "it returns Request must include at least... error" do
    {:error, errors, code} = AuthorizationCodeGrantType.authorize(%{
      "scope" => "some_api:read"
    })

    message = "Request must include at least client_id, client_secret, code, scopes and redirect_uri parameters."
    assert %{invalid_request: message} = errors
    assert :bad_request = code
  end

  test "it returns invalid client id or secret error" do
    client = Mithril.Fixtures.create_client()

    {:error, errors, code} = AuthorizationCodeGrantType.authorize(%{
      "client_id" => "F75029D0-DDBA-4897-A6F2-9A785222FD67",
      "client_secret" => client.secret,
      "code" => "some_code",
      "redirect_uri" => client.redirect_uri,
      "scope" => "some_api:read"
    })

    assert %{invalid_client: "Invalid client id or secret."} = errors
    assert :unauthorized = code
  end

  test "it returns Token Not Found error" do
    client = Mithril.Fixtures.create_client()

    {:error, errors, code} = AuthorizationCodeGrantType.authorize(%{
      "client_id" => client.id,
      "client_secret" => client.secret,
      "code" => "some_code",
      "redirect_uri" => client.redirect_uri,
      "scope" => "some_api:read"
    })

    assert %{invalid_token: "Token not found."} = errors
    assert :unauthorized = code
  end

  test "it returns Resource owner revoked access for the client error" do
    client = Mithril.Fixtures.create_client()
    user   = Mithril.Fixtures.create_user()

    {:ok, code_grant} = Mithril.Fixtures.create_code_grant_token(client, user)

    {:error, errors, code} = AuthorizationCodeGrantType.authorize(%{
      "client_id" => client.id,
      "client_secret" => client.secret,
      "code" => code_grant.value,
      "redirect_uri" => client.redirect_uri,
      "scope" => "some_api:read"
    })

    assert %{access_denied: "Resource owner revoked access for the client."} = errors
    assert :unauthorized = code
  end

  test "it returns redirection URI client error" do
    client = Mithril.Fixtures.create_client()
    user   = Mithril.Fixtures.create_user()

    Mithril.AppAPI.create_app(%{
      user_id: user.id,
      client_id: client.id,
      scope: "some_api:read some_api:write"
    })

    {:ok, code_grant} = Mithril.Fixtures.create_code_grant_token(client, user)

    {:error, errors, code} = AuthorizationCodeGrantType.authorize(%{
      "client_id" => client.id,
      "client_secret" => client.secret,
      "code" => code_grant.value,
      "redirect_uri" => "some_suspicios_uri",
      "scope" => "some_api:read"
    })

    assert %{invalid_client: "The redirection URI provided does not match a pre-registered value."} = errors
    assert :unauthorized = code
  end

  test "it returns token expired error" do
    client = Mithril.Fixtures.create_client()
    user   = Mithril.Fixtures.create_user()

    Mithril.AppAPI.create_app(%{
      user_id: user.id,
      client_id: client.id,
      scope: "some_api:read some_api:write"
    })

    {:ok, code_grant} = Mithril.Fixtures.create_code_grant_token(client, user, 0)

    {:error, errors, code} = AuthorizationCodeGrantType.authorize(%{
      "client_id" => client.id,
      "client_secret" => client.secret,
      "code" => code_grant.value,
      "redirect_uri" => client.redirect_uri,
      "scope" => "some_api:read"
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
      scope: "some_api:read some_api:write"
    })

    client2 = Mithril.Fixtures.create_client(%{name: "Another name"})
    {:ok, code_grant} = Mithril.Fixtures.create_code_grant_token(client2, user)

    {:error, errors, code} = AuthorizationCodeGrantType.authorize(%{
      "client_id" => client.id,
      "client_secret" => client.secret,
      "code" => code_grant.value,
      "redirect_uri" => client.redirect_uri,
      "scope" => "some_api:read"
    })

    assert %{invalid_grant: "Token not found or expired."} = errors
    assert :unauthorized = code
  end
end
