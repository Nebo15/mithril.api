defmodule Mithril.Acceptance.Oauth2FlowTest do
  use Mithril.Web.ConnCase

  test "client successfully obtain an access_token API calls", %{conn: conn} do
    user  = Mithril.Fixtures.create_user(%{password: "super$ecre7"})
    client = Mithril.Fixtures.create_client()

    # 1. User is presented a user-agent and logs in
    login_request_body = %{
      "token" => %{
        "grant_type": "password",
        "email": user.email,
        "password": "super$ecre7",
        "client_id": client.id,
        "scope": "app:authorize"
      }
    }

    conn
    |> put_req_header("accept", "application/json")
    |> post("/oauth/tokens", Poison.encode!(login_request_body))

    # 2. After login user is presented with a list of scopes
    # The request goes through gateway, which
    # converts login_response["data"]["value"] into user_id
    # and puts it in as "x-consumer-id" header
    approval_request_body = %{
      "app" => %{
        "client_id": client.id,
        "redirect_uri": client.redirect_uri,
        "scope": "legal_entity:read,legal_entity:write"
      }
    }

    approval_response =
      conn
      |> put_req_header("x-consumer-id", user.id)
      |> put_req_header("accept", "application/json")
      |> post("/oauth/apps/authorize", Poison.encode!(approval_request_body))

    code_grant =
      approval_response
      |> Map.get(:resp_body)
      |> Poison.decode!
      |> get_in(["data", "value"])

    redirect_uri = "http://localhost?code=#{code_grant}"

    assert [^redirect_uri] = get_resp_header(approval_response, "location")

    # 3. After authorization server responds and
    # user-agent is redirected to client server,
    # client issues an access_token request
    tokens_request_body = %{
      "token" => %{
        "grant_type": "authorization_code",
        "client_id": client.id,
        "client_secret": client.secret,
        "code": code_grant,
        "scope": "legal_entity:read,legal_entity:write",
        "redirect_uri": client.redirect_uri
      }
    }

    tokens_response =
      conn
      |> put_req_header("accept", "application/json")
      |> post("/oauth/tokens", Poison.encode!(tokens_request_body))
      |> Map.get(:resp_body)
      |> Poison.decode!

    assert tokens_response["data"]["name"] == "access_token"
    assert tokens_response["data"]["value"]
    assert tokens_response["data"]["details"]["refresh_token"]
  end
end
