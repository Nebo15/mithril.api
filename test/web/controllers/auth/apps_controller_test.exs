defmodule Mithril.OAuth.AppControllerTest do
  use Mithril.Web.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "successfully approves new client request & issues a code grant", %{conn: conn} do
    client = Mithril.Fixtures.create_client(%{redirect_uri: "http://some_host.com:3000/path?param=1"})
    user   = Mithril.Fixtures.create_user()

    request = %{
      app: %{
        client_id: client.id,
        redirect_uri: client.redirect_uri,
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
    client = Mithril.Fixtures.create_client()
    user   = Mithril.Fixtures.create_user()

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
      conn = post(conn, "/oauth/apps/authorize", Poison.encode!(%{"scope" => "legal_entity:read"}))
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

    assert result = json_response(conn, 400)["error"]
    assert result["invalid_client"] == "Request must include at least client_id, redirect_uri and scopes parameters."
  end
end
