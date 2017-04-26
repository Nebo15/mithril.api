defmodule Mithril.TokenControllerTest do
  use Mithril.Web.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "returns a token", %{conn: conn} do
    client = Mithril.Fixtures.create_client()
    token = Mithril.Fixtures.create_token(%{
      grant_type: "authorization_code",
      scope: "some_scopes",
      client_id: client.id
    })

    conn = get(conn, oauth2_token_path(conn, :show, token.value),
      client_id: client.id, client_secret: client.secret)

    assert Map.drop(json_response(conn, 200)["data"], ["id"]) == %{
      "details" => %{
        "client_id" => client.id,
        "scope" => token.details.scope,
        "grant_type" => "authorization_code"
      },
      "expires_at" => token.expires_at,
      "name" => token.name,
      "value" => token.value,
      "type" => "token"
    }
  end
end
