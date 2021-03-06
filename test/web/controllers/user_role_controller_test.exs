defmodule Mithril.Web.UserRoleControllerTest do
  use Mithril.Web.ConnCase

  alias Mithril.UserAPI.User
  alias Mithril.UserRoleAPI
  import Mithril.Fixtures

  def fixture(:user_role, user_id) do
    {:ok, user_role} =
      user_id
      |> user_role_attrs()
      |> UserRoleAPI.create_user_role()
    user_role
  end

  setup %{conn: conn} do
    {:ok, user} = Mithril.UserAPI.create_user(%{email: "some email", password: "some password", settings: %{}})

    {:ok, conn: put_req_header(conn, "accept", "application/json"), user_id: user.id}
  end

  test "lists all entries on index", %{user_id: user_id, conn: conn} do
    fixture(:user_role, user_id)
    fixture(:user_role, user_id)
    fixture(:user_role, user_id)
    conn = get conn, user_role_path(conn, :index, %User{id: user_id})
    assert 3 == length(json_response(conn, 200)["data"])
  end

  test "does not list all entries on index when limit is set", %{user_id: user_id, conn: conn} do
    fixture(:user_role, user_id)
    fixture(:user_role, user_id)
    fixture(:user_role, user_id)
    conn = get conn, user_role_path(conn, :index, %User{id: user_id}), %{limit: 2}
    assert 2 == length(json_response(conn, 200)["data"])
  end

  test "does not list all entries on index when starting_after is set", %{user_id: user_id, conn: conn} do
    user_role = fixture(:user_role, user_id)
    fixture(:user_role, user_id)
    fixture(:user_role, user_id)
    conn = get conn, user_role_path(conn, :index, %User{id: user_id}), %{starting_after: user_role.id}
    assert 2 == length(json_response(conn, 200)["data"])
  end

  test "does not list all entries on index when ending_before is set", %{user_id: user_id, conn: conn} do
    fixture(:user_role, user_id)
    fixture(:user_role, user_id)
    user_role = fixture(:user_role, user_id)
    conn = get conn, user_role_path(conn, :index, %User{id: user_id}), %{ending_before: user_role.id}
    assert 2 == length(json_response(conn, 200)["data"])
  end

  test "creates user_role and renders user_role when data is valid", %{user_id: user_id, conn: conn} do
    create_attrs = user_role_attrs()
    conn = post conn, user_role_path(conn, :create, %User{id: user_id}), user_role: create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, user_role_path(conn, :show, user_id, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "client_id" => create_attrs.client_id,
      "role_id" => create_attrs.role_id,
      "user_id" => create_attrs.user_id,
    }
  end

  test "does not create user_role and renders errors when data is invalid", %{user_id: user_id, conn: conn} do
    invalid_attrs = %{client_id: nil, role_id: nil}
    conn = post conn, user_role_path(conn, :create, %User{id: user_id}), user_role: invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen user_role", %{conn: conn} do
    create_attrs = user_role_attrs()
    {:ok, user_role} = UserRoleAPI.create_user_role(create_attrs)
    conn = delete conn, user_role_path(conn, :delete, user_role.user_id, user_role.id)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, user_role_path(conn, :show, user_role.user_id, user_role.id)
    end
  end

  test "deletes user_roles by user_id", %{user_id: user_id, conn: conn} do
    fixture(:user_role, user_id)
    fixture(:user_role, user_id)
    {:ok, user} = Mithril.UserAPI.create_user(%{email: "email@example.com", password: "some password", settings: %{}})
    fixture(:user_role, user.id)

    conn = delete conn, user_role_path(conn, :delete_by_user, user_id)
    assert response(conn, 204)

    conn = get conn, user_role_path(conn, :index, %User{id: user_id})
    assert [] == json_response(conn, 200)["data"]

    conn = get conn, user_role_path(conn, :index, %User{id: user.id})
    assert 1 == length(json_response(conn, 200)["data"])
  end

  test "deletes user_roles by user_id and client_id", %{user_id: user_id, conn: conn} do
    %{id: role_id_admin} = create_role(%{name: "ADMIN", user_id: user_id})
    %{id: role_id_doctor} = create_role(%{name: "DOCTOR", user_id: user_id})
    create_user_role(%{role_id: role_id_admin, user_id: user_id})
    create_user_role(%{role_id: role_id_admin, user_id: user_id})
    %{id: user_role_id} = create_user_role(%{role_id: role_id_doctor, user_id: user_id})

    conn = delete conn, user_role_path(conn, :delete_by_user, user_id), [role_name: "ADMIN"]
    assert response(conn, 204)

    conn = get conn, user_role_path(conn, :index, %User{id: user_id})
    assert [user_role] = json_response(conn, 200)["data"]
    assert user_role_id == user_role["id"]
  end
end
