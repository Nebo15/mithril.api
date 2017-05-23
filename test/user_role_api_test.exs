defmodule Mithril.UserRoleAPITest do
  use Mithril.DataCase

  alias Mithril.UserRoleAPI
  alias Mithril.UserRoleAPI.UserRole

  def fixture(:user_role) do
    user_role_attrs = Mithril.Fixtures.user_role_attrs()
    {:ok, user_role} = UserRoleAPI.create_user_role(user_role_attrs)
    user_role
  end

  test "list_user_roles/1 returns all user_roles" do
    user_role = fixture(:user_role)
    assert {user_roles, %Ecto.Paging{}} = UserRoleAPI.list_user_roles(%{"user_id" => user_role.user_id})
    assert List.first(user_roles) == user_role
  end

  test "get_user_role! returns the user_role with given id" do
    user_role = fixture(:user_role)
    assert UserRoleAPI.get_user_role!(user_role.id) == user_role
  end

  test "create_user_role/1 with valid data creates a user_role" do
    attrs = Mithril.Fixtures.user_role_attrs()

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
end
