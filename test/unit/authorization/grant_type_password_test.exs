defmodule Mithril.Authorization.GrantType.PasswordTest do
  use Mithril.DataCase, async: true

  alias Mithril.Authorization.GrantType.Password, as: PasswordGrantType

  test "creates password-granted access token" do
    allowed_scope = "app:authorize legal_entity:read legal_entity:write"
    client_type = Mithril.Fixtures.create_client_type(%{scope: allowed_scope})
    client = Mithril.Fixtures.create_client(%{
      settings: %{"allowed_grant_types" => ["password"]},
      client_type_id: client_type.id
    })
    user = Mithril.Fixtures.create_user(%{password: "somepa$$word"})

    {:ok, token} = PasswordGrantType.authorize(%{
      "email" => user.email,
      "password" => "somepa$$word",
      "client_id" => client.id,
      "scope" => "legal_entity:read",
    })

    assert token.name == "access_token"
    assert token.value
    assert token.expires_at
    assert token.user_id == user.id
    assert token.details.client_id == client.id
    assert token.details.grant_type == "password"
    assert token.details.redirect_uri == client.redirect_uri
    assert token.details.scope == "legal_entity:read"
  end

  test "it returns Incorrect password error" do
    client = Mithril.Fixtures.create_client(%{settings: %{"allowed_grant_types" => ["password"]}})
    user   = Mithril.Fixtures.create_user(%{password: "somepa$$word"})

    {:error, errors, code} = PasswordGrantType.authorize(%{
      "email" => user.email,
      "password" => "incorrect_password",
      "client_id" => client.id,
      "scope" => "legal_entity:read",
    })

    assert %{invalid_grant: "Identity, password combination is wrong."} = errors
    assert :unauthorized = code
  end

  test "it returns User Not Found error" do
    client = Mithril.Fixtures.create_client(%{settings: %{"allowed_grant_types" => ["password"]}})

    {:error, errors, code} = PasswordGrantType.authorize(%{
      "email" => "non_existing_email",
      "password" => "incorrect_password",
      "client_id" => client.id,
      "scope" => "legal_entity:read",
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
      "scope" => "legal_entity:read"
    })

    assert %{invalid_client: "Invalid client id."} = errors
    assert :unauthorized = code
  end

  test "it returns Incorrect Scopes error" do
    allowed_scope = "app:authorize legal_entity:read legal_entity:write"
    client_type = Mithril.Fixtures.create_client_type(%{scope: allowed_scope})
    client = Mithril.Fixtures.create_client(%{
      settings: %{"allowed_grant_types" => ["password"]},
      client_type_id: client_type.id
    })
    user = Mithril.Fixtures.create_user(%{password: "somepa$$word"})

    {:error, errors, code} = PasswordGrantType.authorize(%{
      "email" => user.email,
      "password" => "somepa$$word",
      "client_id" => client.id,
      "scope" => "some_hidden_api:read",
    })

    message = "Allowed scopes for the token are #{Enum.join(String.split(allowed_scope), ", ")}."
    assert %{invalid_scope: ^message} = errors
    assert :bad_request = code
  end

  test "it returns insufficient parameters error" do
    {:error, errors, code} = PasswordGrantType.authorize(%{})

    message = "Request must include at least email, password, client_id and scope parameters."
    assert %{invalid_request: ^message} = errors
    assert :bad_request = code
  end
end
