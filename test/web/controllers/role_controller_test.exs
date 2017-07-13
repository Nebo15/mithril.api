defmodule Mithril.Web.RoleControllerTest do
  use Mithril.Web.ConnCase

  alias Mithril.RoleAPI
  alias Mithril.RoleAPI.Role

  @create_attrs %{name: "some name", scope: "some scope"}
  @update_attrs %{name: "some updated name", scope: "some updated scope"}
  @invalid_attrs %{name: nil, scope: nil}

  def fixture(:role, params \\ %{}) do
    {:ok, role} =
      @create_attrs
      |> Map.merge(params)
      |> RoleAPI.create_role()
    role
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "list roles" do
    test "search by name by like works", %{conn: conn} do
      fixture(:role, %{name: "admin"})
      fixture(:role, %{name: "administrator"})
      fixture(:role, %{name: "user"})
      conn = get conn, role_path(conn, :index), %{name: "min"}
      assert 2 == length(json_response(conn, 200)["data"])
    end

    test "lists all entries on index", %{conn: conn} do
      fixture(:role)
      fixture(:role)
      fixture(:role)
      conn = get conn, role_path(conn, :index)
      assert 3 == length(json_response(conn, 200)["data"])
    end

    test "does not list all entries on index when limit is set", %{conn: conn} do
      fixture(:role)
      fixture(:role)
      fixture(:role)
      conn = get conn, role_path(conn, :index), %{limit: 2}
      assert 2 == length(json_response(conn, 200)["data"])
    end

    test "does not list all entries on index when starting_after is set", %{conn: conn} do
      role = fixture(:role)
      fixture(:role)
      fixture(:role)
      conn = get conn, role_path(conn, :index), %{starting_after: role.id}
      assert 2 == length(json_response(conn, 200)["data"])
    end

    test "does not list all entries on index when ending_before is set", %{conn: conn} do
      fixture(:role)
      fixture(:role)
      role = fixture(:role)
      conn = get conn, role_path(conn, :index), %{ending_before: role.id}
      assert 2 == length(json_response(conn, 200)["data"])
    end

    test "list roles by scopes", %{conn: conn} do
      fixture(:role, %{scope: "some scope"})
      fixture(:role, %{scope: "employee:read employee:write"})
      fixture(:role, %{scope: "employee:read employee:write"})
      scopes = ~w(employee:read employee:write)
      conn = get conn, role_path(conn, :index), %{scope: Enum.join(scopes, ",")}
      resp = json_response(conn, 200)["data"]

      assert 2 == length(resp)
      assert Enum.all?(resp, fn client_type ->
        client_type["scope"]
        |> String.split(" ")
        |> MapSet.new()
        |> MapSet.intersection(MapSet.new(scopes))
        |> Enum.empty?
        |> Kernel.!
      end)
    end
  end

  test "creates role and renders role when data is valid", %{conn: conn} do
    conn = post conn, role_path(conn, :create), role: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, role_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some name",
      "scope" => "some scope",
    }
  end

  test "does not create role and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, role_path(conn, :create), role: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen role and renders role when data is valid", %{conn: conn} do
    %Role{id: id} = role = fixture(:role)
    conn = put conn, role_path(conn, :update, role), role: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, role_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some updated name",
      "scope" => "some updated scope",
    }
  end

  test "does not update chosen role and renders errors when data is invalid", %{conn: conn} do
    role = fixture(:role)
    conn = put conn, role_path(conn, :update, role), role: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen role", %{conn: conn} do
    role = fixture(:role)
    conn = delete conn, role_path(conn, :delete, role)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, role_path(conn, :show, role)
    end
  end
end
