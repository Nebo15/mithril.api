defmodule Mithril.Authorization.GrantType.AuthorizationCodeTest do
  use Mithril.DataCase, async: true

  alias Mithril.Authorization.GrantType.AuthorizationCode, as: AuthorizationCodeGrantType

  def code_grant_token(client, user) do
    Mithril.TokenAPI.create_token(%{
      details: %{
        scope: "app:authorize",
        client_id: client.id,
        grant_type: "password",
        redirect_uri: client.redirect_uri
      },
      user_id: user.id,
      expires_at: 2000000001,
      name: "authorization_code",
      value: "some_short_lived_code"
    })
  end

  test "creates code-granted access token" do
    client = Mithril.Fixtures.create_client()
    user   = Mithril.Fixtures.create_user()

    Mithril.AppAPI.create_app(%{
      user_id: user.id,
      client_id: client.id,
      scope: "some_api:read,some_api:write"
    })

    {:ok, code_grant} = code_grant_token(client, user)

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
    assert token.details.grant_type == "authorization_code"
    assert token.details.redirect_uri == client.redirect_uri
    assert token.details.scope == "some_api:read"
  end

  @tag pending: true
  test "it returns Request must include at least... error" do
  end

  @tag pending: true
  test "it returns invalid client id or secret error" do
  end

  @tag pending: true
  test "it returns Token Not Found error" do
  end

  @tag pending: true
  test "it returns Resource owner revoked access for the client error" do
  end

  @tag pending: true
  test "it returns redirection URI client error" do
  end

  @tag pending: true
  test "it returns token expired error" do
  end

  @tag pending: true
  test "it returns token not found or expired error" do
  end
end
