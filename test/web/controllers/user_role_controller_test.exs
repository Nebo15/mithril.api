defmodule Trump.Web.UserRoleControllerTest do
  use Trump.Web.ConnCase

  alias Trump.Web.UserAPI.User
  alias Trump.RoleAPI
  alias Trump.UserRoleAPI
  alias Trump.ClientAPI

  setup %{conn: conn} do
    {:ok, user} = Trump.Web.UserAPI.create_user(%{email: "some email", password: "some password", settings: %{}})

    {:ok, conn: put_req_header(conn, "accept", "application/json"), user_id: user.id}
  end

  test "lists all entries on index", %{user_id: user_id, conn: conn} do
    conn = get conn, user_role_path(conn, :index, %User{id: user_id})
    assert json_response(conn, 200)["data"] == []
  end

  test "creates user_role and renders user_role when data is valid", %{user_id: user_id, conn: conn} do
    client_attrs = %{
      name: "some name",
      priv_settings: %{},
      redirect_uri: "some redirect_uri",
      secret: "some secret",
      user_id: elem(Trump.Web.UserAPI.create_user(%{email: "some new email", password: "some password", settings: %{}}), 1).id,
      client_type_id: elem(Trump.ClientTypeAPI.create_client_type(%{name: "some_kind_of_client", scope: "some, scope"}), 1).id,
      settings: %{}
    }

    create_attrs = %{
      client_id: elem(ClientAPI.create_client(client_attrs), 1).id,
      role_id: elem(RoleAPI.create_role(%{name: "some name", scope: "some scope"}), 1).id
    }

    conn = post conn, user_role_path(conn, :create, %User{id: user_id}), user_role: create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, user_role_path(conn, :show, user_id, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "client_id" => create_attrs.client_id,
      "role_id" => create_attrs.role_id,
      "user_id" => user_id,
      "type" => "user_role"}
  end

  test "does not create user_role and renders errors when data is invalid", %{user_id: user_id, conn: conn} do
    invalid_attrs = %{client_id: nil, role_id: nil}
    conn = post conn, user_role_path(conn, :create, %User{id: user_id}), user_role: invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen user_role", %{user_id: user_id, conn: conn} do
    client_attrs = %{
      name: "some name",
      priv_settings: %{},
      redirect_uri: "some redirect_uri",
      secret: "some secret",
      user_id: elem(Trump.Web.UserAPI.create_user(%{email: "some new email", password: "some password", settings: %{}}), 1).id,
      client_type_id: elem(Trump.ClientTypeAPI.create_client_type(%{name: "some_kind_of_client", scope: "some, scope"}), 1).id,
      settings: %{}
    }

    create_attrs = %{
      client_id: elem(ClientAPI.create_client(client_attrs), 1).id,
      role_id: elem(RoleAPI.create_role(%{name: "some name", scope: "some scope"}), 1).id
    }

    {:ok, user_role} = UserRoleAPI.create_user_role(Map.put_new(create_attrs, :user_id, user_id))
    conn = delete conn, user_role_path(conn, :delete, user_role.user_id, user_role.id)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, user_role_path(conn, :show, user_role.user_id, user_role.id)
    end
  end
end
