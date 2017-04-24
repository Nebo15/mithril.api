defmodule Trump.UserRoleAPITest do
  use Trump.DataCase

  alias Trump.UserRoleAPI
  alias Trump.ClientAPI
  alias Trump.RoleAPI
  alias Trump.UserRoleAPI.UserRole

  def fixture(:user_role) do
    client_attrs = %{
      name: "some name",
      priv_settings: %{},
      redirect_uri: "some redirect_uri",
      secret: "some secret",
      user_id: elem(Trump.Web.UserAPI.create_user(%{email: "some new email", password: "some password", settings: %{}}), 1).id,
      settings: %{}
    }

    attrs = %{
      user_id: elem(Trump.Web.UserAPI.create_user(%{email: "some email", password: "some password", settings: %{}}), 1).id,
      client_id: elem(ClientAPI.create_client(client_attrs), 1).id,
      role_id: elem(RoleAPI.create_role(%{name: "some name", scope: "some scope"}), 1).id
    }

    {:ok, user_role} = UserRoleAPI.create_user_role(attrs)
    user_role
  end

  test "list_user_roles/1 returns all user_roles" do
    user_role = fixture(:user_role)
    assert UserRoleAPI.list_user_roles(user_role.user_id) == [user_role]
  end

  test "get_user_role! returns the user_role with given id" do
    user_role = fixture(:user_role)
    assert UserRoleAPI.get_user_role!(user_role.id) == user_role
  end

  test "create_user_role/1 with valid data creates a user_role" do
    client_attrs = %{
      name: "some name",
      priv_settings: %{},
      redirect_uri: "some redirect_uri",
      secret: "some secret",
      user_id: elem(Trump.Web.UserAPI.create_user(%{email: "some new email", password: "some password", settings: %{}}), 1).id,
      settings: %{}
    }

    attrs = %{
      user_id: elem(Trump.Web.UserAPI.create_user(%{email: "some email", password: "some password", settings: %{}}), 1).id,
      client_id: elem(ClientAPI.create_client(client_attrs), 1).id,
      role_id: elem(RoleAPI.create_role(%{name: "some name", scope: "some scope"}), 1).id
    }

    assert {:ok, %UserRole{} = user_role} = UserRoleAPI.create_user_role(attrs)
    assert user_role.client_id == attrs.client_id
    assert user_role.role_id == attrs.role_id
    assert user_role.user_id == attrs.user_id
  end

  test "create_user_role/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = UserRoleAPI.create_user_role(%{client_id: nil, role_id: nil, user_id: nil})
  end

  test "delete_user_role/1 deletes the user_role" do
    user_role = fixture(:user_role)
    assert {:ok, %UserRole{}} = UserRoleAPI.delete_user_role(user_role)
    assert_raise Ecto.NoResultsError, fn -> UserRoleAPI.get_user_role!(user_role.id) end
  end

  test "change_user_role/1 returns a user_role changeset" do
    user_role = fixture(:user_role)
    assert %Ecto.Changeset{} = UserRoleAPI.change_user_role(user_role)
  end
end
