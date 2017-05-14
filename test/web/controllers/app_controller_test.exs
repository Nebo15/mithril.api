defmodule Mithril.Web.AppControllerTest do
  use Mithril.Web.ConnCase

  alias Mithril.AppAPI
  alias Mithril.AppAPI.App

  @create_attrs %{scope: "some scope"}
  @update_attrs %{scope: "some updated scope"}
  @invalid_attrs %{scope: nil}

  def fixture(:app) do
    user  = Mithril.Fixtures.create_user()
    client = Mithril.Fixtures.create_client()

    attrs = Map.merge(@create_attrs, %{user_id: user.id, client_id: client.id})
    {:ok, app} = AppAPI.create_app(attrs)
    app
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, app_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates app and renders app when data is valid", %{conn: conn} do
    user  = Mithril.Fixtures.create_user()
    client = Mithril.Fixtures.create_client()

    attrs = Map.merge(@create_attrs, %{user_id: user.id, client_id: client.id})
    conn = post conn, app_path(conn, :create), app: attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, app_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "scope" => "some scope",
      "type" => "app"}
  end

  test "does not create app and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, app_path(conn, :create), app: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen app and renders app when data is valid", %{conn: conn} do
    %App{id: id} = app = fixture(:app)
    conn = put conn, app_path(conn, :update, app), app: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, app_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "scope" => "some updated scope",
      "type" => "app"}
  end

  test "does not update chosen app and renders errors when data is invalid", %{conn: conn} do
    app = fixture(:app)
    conn = put conn, app_path(conn, :update, app), app: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen app", %{conn: conn} do
    app = fixture(:app)
    conn = delete conn, app_path(conn, :delete, app)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, app_path(conn, :show, app)
    end
  end
end
