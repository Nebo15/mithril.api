defmodule Mithril.OAuth.TokenControllerTest do
  use Mithril.Web.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "successfully issues new access_token using using password", %{conn: conn} do
    client = Mithril.Fixtures.create_client(%{settings: %{"allowed_grant_types" => ["password"]}})
    user   = Mithril.Fixtures.create_user(%{password: "secret_password"})

    request_payload = %{
      "token": %{
        "grant_type": "password",
        "email": user.email,
        "password": "secret_password",
        "client_id": client.id,
        "scope": "app:authorize"
      }
    }

    conn = post(conn, "/oauth/tokens", Poison.encode!(request_payload))

    token = json_response(conn, 201)["data"]

    assert token["name"] == "access_token"
    assert token["value"]
    assert token["expires_at"]
    assert token["user_id"] == user.id
    assert token["details"]["client_id"] == client.id
    assert token["details"]["grant_type"] == "password"
    assert token["details"]["redirect_uri"] == client.redirect_uri
    assert token["details"]["scope"] == "app:authorize"
  end

  test "successfully issues new access_token using code_grant", %{conn: conn} do
    client = Mithril.Fixtures.create_client()
    user   = Mithril.Fixtures.create_user(%{password: "secret_password"})

    Mithril.AppAPI.create_app(%{
      user_id: user.id,
      client_id: client.id,
      scope: "some_api:read some_api:write"
    })

    {:ok, code_grant} = Mithril.Fixtures.create_code_grant_token(client, user)

    request_payload = %{
      "token": %{
        "grant_type" => "authorization_code",
        "client_id" => client.id,
        "client_secret" => client.secret,
        "redirect_uri" => client.redirect_uri,
        "code" => code_grant.value,
        "scope" => "some_api:read"
      }
    }

    conn = post(conn, "/oauth/tokens", Poison.encode!(request_payload))

    token = json_response(conn, 201)["data"]

    assert token["name"] == "access_token"
    assert token["value"]
    assert token["expires_at"]
    assert token["user_id"] == user.id
    assert token["details"]["client_id"] == client.id
    assert token["details"]["grant_type"] == "authorization_code"
    assert token["details"]["redirect_uri"] == client.redirect_uri
    assert token["details"]["scope"] == "some_api:read"
  end

  test "incorrectly crafted body is still treated nicely", %{conn: conn} do
    assert_error_sent 400, fn ->
      conn = post(conn, "/oauth/tokens", Poison.encode!(%{"scope" => "some_api:read"}))
    end
  end

  test "errors are rendered as json", %{conn: conn} do
    request = %{
      "token" => %{
        "scope" => "some_api:read"
      }
    }

    conn = post(conn, "/oauth/tokens", Poison.encode!(request))

    result = json_response(conn, 400)["error"]
    assert result["invalid_client"] == "Request must include grant_type."
  end
end
