defmodule Mithril.OAuth.AppControllerTest do
  use Mithril.Web.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "successfully approves new client request & issues a code grant", %{conn: conn} do
    client_type = Mithril.Fixtures.create_client_type(%{scope: "legal_entity:read legal_entity:write"})
    client = Mithril.Fixtures.create_client(%{redirect_uri: "http://some_host.com:3000/"})
    user   = Mithril.Fixtures.create_user()
    user_role = Mithril.Fixtures.create_role(%{scope: "legal_entity:read legal_entity:write"})
    Mithril.UserRoleAPI.create_user_role(%{user_id: user.id, role_id: user_role.id, client_id: client.id})
    redirect_uri = "#{client.redirect_uri}path?param=1"

    request = %{
      app: %{
        client_id: client.id,
        redirect_uri: redirect_uri,
        scope: "legal_entity:read legal_entity:write",
      }
    }

    # This request is expected to be made by our own front-end.
    # Gateway must have /oauth/apps/authorize route & related ACL/auth/proxy enabled
    conn =
      conn
      |> put_req_header("x-consumer-id", user.id)
      |> post("/oauth/apps/authorize", Poison.encode!(request))

    result = json_response(conn, 201)["data"]

    assert result["value"]
    assert result["user_id"]
    assert result["name"] == "authorization_code"
    assert result["expires_at"]
    assert result["details"]["scope"] == "app:authorize"
    assert result["details"]["redirect_uri"]
    assert result["details"]["client_id"]
    assert result["details"]["grant_type"] == "password"

    [header] = Plug.Conn.get_resp_header(conn, "location")

    assert "http://some_host.com:3000/path?code=#{result["value"]}&param=1" == header

    app = Mithril.AppAPI.get_app_by([user_id: user.id, client_id: client.id])

    assert app.user_id == user.id
    assert app.client_id == client.id
    assert app.scope == "legal_entity:read legal_entity:write"
  end

  test "successfully updates existing approval with more scopes", %{conn: conn} do
    client_type = Mithril.Fixtures.create_client_type(%{scope: "legal_entity:read legal_entity:write"})
    client = Mithril.Fixtures.create_client(%{redirect_uri: "http://some_host.com:3000/"})
    user   = Mithril.Fixtures.create_user()
    user_role = Mithril.Fixtures.create_role(%{scope: "legal_entity:read legal_entity:write"})
    Mithril.UserRoleAPI.create_user_role(%{user_id: user.id, role_id: user_role.id, client_id: client.id})

    Mithril.AppAPI.create_app(%{
      user_id: user.id,
      client_id: client.id,
      scope: "legal_entity:read"
    })

    request = %{
      app: %{
        client_id: client.id,
        redirect_uri: client.redirect_uri,
        scope: "legal_entity:write",
      }
    }

    conn =
      conn
      |> put_req_header("x-consumer-id", user.id)
      |> post("/oauth/apps/authorize", Poison.encode!(request))

    result = json_response(conn, 201)["data"]

    assert result["name"] == "authorization_code"
    assert result["details"]["scope"] == "app:authorize"

    app = Mithril.AppAPI.get_app_by([user_id: user.id, client_id: client.id])

    assert app.user_id == user.id
    assert app.client_id == client.id
    assert app.scope == "legal_entity:read legal_entity:write"
  end

  test "incorrectly crafted body is still treated nicely", %{conn: conn} do
    assert_error_sent 400, fn ->
      post(conn, "/oauth/apps/authorize", Poison.encode!(%{"scope" => "legal_entity:read"}))
    end
  end

  test "errors are rendered as json", %{conn: conn} do
    request = %{
      "app" => %{
        "scope" => "legal_entity:read"
      }
    }

    conn =
      conn
      |> put_req_header("x-consumer-id", "F003D59D-3E7A-40E0-8207-7EC05C3303FF")
      |> post("/oauth/apps/authorize", Poison.encode!(request))

    result = json_response(conn, 400)["error"]
    assert result["invalid_client"] == "Request must include at least client_id, redirect_uri and scopes parameters."
  end

  test "returns error when redirect uri is not whitelisted", %{conn: conn} do
    client_type = Mithril.Fixtures.create_client_type(%{scope: "legal_entity:read legal_entity:write"})
    client = Mithril.Fixtures.create_client(%{redirect_uri: "http://some_host.com:3000/"})
    user   = Mithril.Fixtures.create_user()
    user_role = Mithril.Fixtures.create_role(%{scope: "legal_entity:read legal_entity:write"})
    Mithril.UserRoleAPI.create_user_role(%{user_id: user.id, role_id: user_role.id, client_id: client.id})
    redirect_uri = "http://some_other_host.com:3000/path?param=1"

    request = %{
      app: %{
        client_id: client.id,
        redirect_uri: redirect_uri,
        scope: "legal_entity:read legal_entity:write",
      }
    }

    # This request is expected to be made by our own front-end.
    # Gateway must have /oauth/apps/authorize route & related ACL/auth/proxy enabled
    conn =
      conn
      |> put_req_header("x-consumer-id", user.id)
      |> post("/oauth/apps/authorize", Poison.encode!(request))

    result = json_response(conn, 422)["error"]

    message = "The redirection URI provided does not match a pre-registered value."
    assert %{"invalid_client" => ^message} = result
  end

  test "validates list of available client scopes", %{conn: conn} do
    client_type = Mithril.Fixtures.create_client_type(%{scope: "b c d"})
    client = Mithril.Fixtures.create_client(%{client_type_id: client_type.id})
    user = Mithril.Fixtures.create_user()
    user_role = Mithril.Fixtures.create_role(%{scope: "a b c"})
    Mithril.UserRoleAPI.create_user_role(%{user_id: user.id, role_id: user_role.id, client_id: client.id})

    request = %{
      app: %{
        client_id: client.id,
        redirect_uri: client.redirect_uri,
        scope: "b c d",
      }
    }

    # This request is expected to be made by our own front-end.
    # Gateway must have /oauth/apps/authorize route & related ACL/auth/proxy enabled
    conn =
      conn
      |> put_req_header("x-consumer-id", user.id)
      |> post("/oauth/apps/authorize", Poison.encode!(request))

    result = json_response(conn, 422)["error"]

    message = "User requested scope is not allowed by role based access policies."
    assert %{"invalid_client" => ^message} = result
  end
end
