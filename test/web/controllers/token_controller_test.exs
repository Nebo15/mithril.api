defmodule Mithril.Web.TokenControllerTest do
  use Mithril.Web.ConnCase

  alias Mithril.TokenAPI
  alias Mithril.TokenAPI.Token

  @create_attrs %{details: %{}, expires_at: 42, name: "some name", value: "some value"}
  @update_attrs %{details: %{}, expires_at: 43, name: "some updated name", value: "some updated value"}
  @invalid_attrs %{details: nil, expires_at: nil, name: nil, value: nil}

  def fixture(:token) do
    {:ok, token} = TokenAPI.create_token(@create_attrs)
    token
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, token_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates token and renders token when data is valid", %{conn: conn} do
    conn = post conn, token_path(conn, :create), token: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, token_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "details" => %{},
      "expires_at" => 42,
      "name" => "some name",
      "value" => "some value",
      "type" => "token"}
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
      "type" => "token"}
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
end
