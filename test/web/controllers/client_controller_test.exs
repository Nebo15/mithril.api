defmodule Trump.Web.ClientControllerTest do
  use Trump.Web.ConnCase

  alias Trump.ClientAPI
  alias Trump.ClientAPI.Client

  @create_attrs %{
    name: "some name",
    priv_settings: %{},
    redirect_uri: "some redirect_uri",
    secret: "some secret",
    settings: %{}
  }

  @update_attrs %{
    name: "some updated name",
    priv_settings: %{},
    redirect_uri: "some updated redirect_uri",
    secret: "some updated secret",
    settings: %{}
  }

  @invalid_attrs %{
    name: nil,
    priv_settings: nil,
    redirect_uri: nil,
    secret: nil,
    settings: nil
  }

  def fixture(:client) do
    {:ok, client} = ClientAPI.create_client(@create_attrs)
    client
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, client_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates client and renders client when data is valid", %{conn: conn} do
    conn = post conn, client_path(conn, :create), client: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, client_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some name",
      "priv_settings" => %{},
      "redirect_uri" => "some redirect_uri",
      "secret" => "some secret",
      "settings" => %{},
      "type" => "client"}
  end

  test "does not create client and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, client_path(conn, :create), client: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen client and renders client when data is valid", %{conn: conn} do
    %Client{id: id} = client = fixture(:client)
    conn = put conn, client_path(conn, :update, client), client: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, client_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some updated name",
      "priv_settings" => %{},
      "redirect_uri" => "some updated redirect_uri",
      "secret" => "some updated secret",
      "settings" => %{},
      "type" => "client"}
  end

  test "does not update chosen client and renders errors when data is invalid", %{conn: conn} do
    client = fixture(:client)
    conn = put conn, client_path(conn, :update, client), client: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen client", %{conn: conn} do
    client = fixture(:client)
    conn = delete conn, client_path(conn, :delete, client)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, client_path(conn, :show, client)
    end
  end
end
