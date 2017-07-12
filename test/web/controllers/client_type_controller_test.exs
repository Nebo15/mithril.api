defmodule Mithril.Web.ClientTypeControllerTest do
  use Mithril.Web.ConnCase

  alias Mithril.ClientTypeAPI
  alias Mithril.ClientTypeAPI.ClientType

  @create_attrs %{name: "some name", scope: "some scope"}
  @update_attrs %{name: "some updated name", scope: "some updated scope"}
  @invalid_attrs %{name: nil, scope: nil}

  def fixture(:client_type, params \\ %{}) do
    {:ok, client_type} = ClientTypeAPI.create_client_type(Map.merge(@create_attrs, params))
    client_type
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "list client types" do
    test "lists all entries on index", %{conn: conn} do
      fixture(:client_type)
      fixture(:client_type)
      fixture(:client_type)
      conn = get conn, client_type_path(conn, :index)
      assert 3 == length(json_response(conn, 200)["data"])
    end

    test "does not list all entries on index when limit is set", %{conn: conn} do
      fixture(:client_type)
      fixture(:client_type)
      fixture(:client_type)
      conn = get conn, client_type_path(conn, :index), %{limit: 2}
      assert 2 == length(json_response(conn, 200)["data"])
    end

    test "does not list all entries on index when starting_after is set", %{conn: conn} do
      client_type = fixture(:client_type)
      fixture(:client_type)
      fixture(:client_type)
      conn = get conn, client_type_path(conn, :index), %{starting_after: client_type.id}
      assert 2 == length(json_response(conn, 200)["data"])
    end

    test "does not list all entries on index when ending_before is set", %{conn: conn} do
      fixture(:client_type)
      fixture(:client_type)
      client_type = fixture(:client_type)
      conn = get conn, client_type_path(conn, :index), %{ending_before: client_type.id}
      assert 2 == length(json_response(conn, 200)["data"])
    end

    test "search client types by name", %{conn: conn} do
      name = "MSP"
      fixture(:client_type)
      {:ok, _} = name |> Mithril.Fixtures.client_type_attrs() |> ClientTypeAPI.create_client_type()

      conn = get conn, client_type_path(conn, :index, [name: name])
      resp = json_response(conn, 200)

      assert Map.has_key?(resp, "paging")
      assert 1 == length(resp["data"])
      refute resp["paging"]["has_more"]
    end

    test "list client types by scopes", %{conn: conn} do
      fixture(:client_type, %{scope: "some scope"})
      fixture(:client_type, %{scope: "employee:read"})
      fixture(:client_type, %{scope: "employee:write"})
      scopes = ~w(employee:read employee:write)
      conn = get conn, client_type_path(conn, :index), %{scope: Enum.join(scopes, ",")}
      resp = json_response(conn, 200)["data"]
      assert 2 == length(resp)
      assert Enum.all?(resp, &(Enum.member?(scopes, Map.get(&1, "scope"))))
    end
  end

  test "creates client_type and renders client_type when data is valid", %{conn: conn} do
    conn = post conn, client_type_path(conn, :create), client_type: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, client_type_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some name",
      "scope" => "some scope",
    }
  end

  test "does not create client_type and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, client_type_path(conn, :create), client_type: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen client_type and renders client_type when data is valid", %{conn: conn} do
    %ClientType{id: id} = client_type = fixture(:client_type)
    conn = put conn, client_type_path(conn, :update, client_type), client_type: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, client_type_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some updated name",
      "scope" => "some updated scope",
    }
  end

  test "does not update chosen client_type and renders errors when data is invalid", %{conn: conn} do
    client_type = fixture(:client_type)
    conn = put conn, client_type_path(conn, :update, client_type), client_type: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen client_type", %{conn: conn} do
    client_type = fixture(:client_type)
    conn = delete conn, client_type_path(conn, :delete, client_type)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, client_type_path(conn, :show, client_type)
    end
  end
end
