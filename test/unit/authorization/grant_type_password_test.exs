defmodule Mithril.Authorization.GrantType.PasswordTest do
  use Mithril.DataCase, async: true

  alias Mithril.Authorization.GrantType.Password, as: PasswordGrantType

  test "creates password-granted access token" do
    client = Mithril.Fixtures.create_client()
    user   = Mithril.Fixtures.create_user(%{password: "somepa$$word"})

    {:ok, token} = PasswordGrantType.authorize(%{
      "email" => user.email,
      "password" => "somepa$$word",
      "client_id" => client.id,
      "scope" => "some_api:read",
    })

    assert token.name == "access_token"
    assert token.value
    assert token.expires_at
    assert token.user_id == user.id
    assert token.details.client_id == client.id #."9b73db0e-e2c1-4ecc-b946-5d18ca110c8d"
    assert token.details.grant_type == "password"
    assert token.details.redirect_uri == client.redirect_uri
    assert token.details.scope == "some_api:read"
  end

  # Different test
  @tag pending: true
  test "creates authentication-code-granted access token" do
    
  end

  # Different test
  @tag pending: true
  test "creates refresh-token-granted access token" do
    
  end

  test "it returns Incorrect password error" do
    client = Mithril.Fixtures.create_client()
    user   = Mithril.Fixtures.create_user(%{password: "somepa$$word"})

    {:error, errors, code} = PasswordGrantType.authorize(%{
      "email" => user.email,
      "password" => "incorrect_password",
      "client_id" => client.id,
      "scope" => "some_api:read",
    })

    assert %{invalid_grant: "Identity, password combination is wrong."} = errors
    assert :unauthorized = code
  end

  test "it returns User Not Found error" do
    client = Mithril.Fixtures.create_client()

    {:error, errors, code} = PasswordGrantType.authorize(%{
      "email" => "non_existing_email",
      "password" => "incorrect_password",
      "client_id" => client.id,
      "scope" => "some_api:read",
    })

    assert %{invalid_grant: "Identity not found."} = errors
    assert :unauthorized = code
  end

  test "it returns Client Not Found error" do
    user = Mithril.Fixtures.create_user(%{password: "somepa$$word"})

    {:error, errors, code} = PasswordGrantType.authorize(%{
      "email" => user.email,
      "password" => "somepa$$word",
      "client_id" => "391374D3-A05D-403B-9290-E0BAAC5CCA21",
      "scope" => "some_api:read"
    })

    assert %{invalid_client: "Invalid client id."} = errors
    assert :unauthorized = code
  end

  test "it returns Incorrect Scopes error" do
    client = Mithril.Fixtures.create_client()
    user   = Mithril.Fixtures.create_user(%{password: "somepa$$word"})

    {:error, errors, code} = PasswordGrantType.authorize(%{
      "email" => user.email,
      "password" => "somepa$$word",
      "client_id" => client.id,
      "scope" => "some_hidden_api:read",
    })

    assert %{invalid_scope: "Allowed scopes for the token are app:authorize, some_api:read, some_api:write, legal_entity:read, legal_entity:write, employee_request:write, employee_request:read."} = errors
    assert :bad_request = code
  end

  test "it returns insufficient parameters error" do
    {:error, errors, code} = PasswordGrantType.authorize(%{})

    assert %{invalid_request: "Request must include at least email, password and client_id parameters."} = errors
    assert :bad_request = code
  end
end
