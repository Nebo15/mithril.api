defmodule Mithril.Web.TokenControllerTest do
  use Mithril.Web.ConnCase

  alias Ecto.UUID
  alias Mithril.TokenAPI
  alias Mithril.TokenAPI.Token

  @create_attrs %{details: %{}, expires_at: 42, name: "some name", value: "some value"}
  @update_attrs %{details: %{}, expires_at: 43, name: "some updated name", value: "some updated value"}
  @invalid_attrs %{details: nil, expires_at: nil, name: nil, value: nil}

  def fixture(:token, name \\ "some name", value \\ "some_value", details \\ %{}) do
    user = Mithril.Fixtures.create_user()
    {:ok, token} =
      @create_attrs
      |> Map.put_new(:user_id, user.id)
      |> Map.put(:name, name)
      |> Map.put(:value, value)
      |> Map.put(:details, details)
      |> TokenAPI.create_token()
    token
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    fixture(:token, "1")
    fixture(:token, "2")
    fixture(:token, "3")
    conn = get conn, token_path(conn, :index)
    assert 3 == length(json_response(conn, 200)["data"])
  end

  test "lists with filter by client_id", %{conn: conn} do
    client_1 = UUID.generate()
    client_2 = UUID.generate()

    fixture(:token, "1", "val", %{"client_id" => client_1})
    fixture(:token, "2", "val", %{"client_id" => client_1})
    fixture(:token, "3", "val", %{"client_id" => client_2})

    conn = get conn, token_path(conn, :index), %{"client_id" => client_1}
    assert 2 == length(json_response(conn, 200)["data"])
  end

  test "does not list all entries on index when limit is set", %{conn: conn} do
    fixture(:token, "1")
    fixture(:token, "2")
    fixture(:token, "3")
    conn = get conn, token_path(conn, :index), %{limit: 2}
    assert 2 == length(json_response(conn, 200)["data"])
  end

  test "does not list all entries on index when starting_after is set", %{conn: conn} do
    token = fixture(:token, "1")
    fixture(:token, "2")
    fixture(:token, "3")
    conn = get conn, token_path(conn, :index), %{starting_after: token.id}
    assert 2 == length(json_response(conn, 200)["data"])
  end

  test "does not list all entries on index when ending_before is set", %{conn: conn} do
    fixture(:token, "1")
    fixture(:token, "2")
    token = fixture(:token, "3")
    conn = get conn, token_path(conn, :index), %{ending_before: token.id}
    assert 2 == length(json_response(conn, 200)["data"])
  end

  test "search by name by like works", %{conn: conn} do
    fixture(:token, "refresh_token")
    fixture(:token, "access_token")
    fixture(:token, "something_different")
    conn = get conn, token_path(conn, :index), %{name: "token"}
    assert 2 == length(json_response(conn, 200)["data"])
  end

  test "search by value by like works", %{conn: conn} do
    fixture(:token, "access_token", "111")
    fixture(:token, "access_token", "123")
    fixture(:token, "access_token", "234")
    conn = get conn, token_path(conn, :index), %{value: "23"}
    assert 2 == length(json_response(conn, 200)["data"])
  end

  test "search by user_id works", %{conn: conn} do
    token = fixture(:token, "1")
    fixture(:token, "2")
    fixture(:token, "3")
    conn = get conn, token_path(conn, :index), %{user_id: token.user_id}
    assert 1 == length(json_response(conn, 200)["data"])
  end

  test "creates token and renders token when data is valid", %{conn: conn} do
    user = Mithril.Fixtures.create_user()
    conn = post conn, token_path(conn, :create), token: Map.put_new(@create_attrs, :user_id, user.id)
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, token_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "details" => %{},
      "expires_at" => 42,
      "name" => "some name",
      "value" => "some value",
      "user_id" => user.id}
  end

  test "does not create token and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, token_path(conn, :create), token: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen token and renders token when data is valid", %{conn: conn} do
    %Token{id: id} = token = fixture(:token)
    conn = put conn, token_path(conn, :update, token), token: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, token_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "details" => %{},
      "expires_at" => 43,
      "name" => "some updated name",
      "value" => "some updated value",
      "user_id" => token.user_id}
  end

  test "does not update chosen token and renders errors when data is invalid", %{conn: conn} do
    token = fixture(:token)
    conn = put conn, token_path(conn, :update, token), token: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen token", %{conn: conn} do
    token = fixture(:token)
    conn = delete conn, token_path(conn, :delete, token)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, token_path(conn, :show, token)
    end
  end

  test "render additional info about user", %{conn: conn} do
    client = Mithril.Fixtures.create_client()
    user   = Mithril.Fixtures.create_user()

    {:ok, role} = Mithril.RoleAPI.create_role(%{name: "Some role", scope: "legal_entity:read"})
    {:ok, _} = Mithril.UserRoleAPI.create_user_role(%{
      client_id: client.id,
      user_id: user.id,
      role_id: role.id
    })

    Mithril.AppAPI.create_app(%{
      user_id: user.id,
      client_id: client.id,
      scope: "legal_entity:read,legal_entity:write"
    })

    {:ok, token} = Mithril.Fixtures.create_access_token(client, user)

    conn = get conn, token_user_path(conn, :user, token.value)

    response = json_response(conn, 200)["data"]

    assert response["id"] == user.id
    assert response["email"] == user.email
    assert response["settings"] == %{}
    assert hd(response["urgent"]["roles"])["name"] == "Some role"
    assert hd(response["urgent"]["roles"])["scope"] == "legal_entity:read"
    assert response["urgent"]["token"]["expires_at"] == token.expires_at
  end

  test "verify token using token value", %{conn: conn} do
    client = Mithril.Fixtures.create_client()
    user   = Mithril.Fixtures.create_user()

    Mithril.AppAPI.create_app(%{
      user_id: user.id,
      client_id: client.id,
      scope: "legal_entity:read,legal_entity:write"
    })

    {:ok, token} = Mithril.Fixtures.create_code_grant_token(client, user)

    conn = get conn, token_verify_path(conn, :verify, token.value)

    token = json_response(conn, 200)["data"]

    assert token["name"] == "authorization_code"
    assert token["value"]
    assert token["expires_at"]
    assert token["user_id"] == user.id
    assert token["details"]["client_id"] == client.id
    assert token["details"]["grant_type"] == "password"
    assert token["details"]["redirect_uri"] == client.redirect_uri
    assert token["details"]["scope"] == "app:authorize"
  end

  test "returns error during token verification", %{conn: conn} do
    token = fixture(:token)

    conn = get conn, token_verify_path(conn, :verify, token.value)

    error = json_response(conn, 401)["error"]

    assert error == %{"invalid_grant" => "Token expired or client approval was revoked."}
  end
end
