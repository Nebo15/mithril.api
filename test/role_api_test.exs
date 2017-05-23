defmodule Mithril.RoleAPITest do
  use Mithril.DataCase

  alias Mithril.RoleAPI
  alias Mithril.RoleAPI.Role

  @create_attrs %{name: "some name", scope: "some scope"}
  @update_attrs %{name: "some updated name", scope: "some updated scope"}
  @invalid_attrs %{name: nil, scope: nil}

  def fixture(:role, attrs \\ @create_attrs) do
    {:ok, role} = RoleAPI.create_role(attrs)
    role
  end

  test "list_roles/1 returns all roles" do
    role = fixture(:role)
    assert {roles, %Ecto.Paging{}} = RoleAPI.list_roles()
    assert List.first(roles) == role
  end

  test "get_role! returns the role with given id" do
    role = fixture(:role)
    assert RoleAPI.get_role!(role.id) == role
  end

  test "create_role/1 with valid data creates a role" do
    assert {:ok, %Role{} = role} = RoleAPI.create_role(@create_attrs)
    assert role.name == "some name"
    assert role.scope == "some scope"
  end

  test "create_role/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = RoleAPI.create_role(@invalid_attrs)
  end

  test "update_role/2 with valid data updates the role" do
    role = fixture(:role)
    assert {:ok, role} = RoleAPI.update_role(role, @update_attrs)
    assert %Role{} = role
    assert role.name == "some updated name"
    assert role.scope == "some updated scope"
  end

  test "update_role/2 with invalid data returns error changeset" do
    role = fixture(:role)
    assert {:error, %Ecto.Changeset{}} = RoleAPI.update_role(role, @invalid_attrs)
    assert role == RoleAPI.get_role!(role.id)
  end

  test "delete_role/1 deletes the role" do
    role = fixture(:role)
    assert {:ok, %Role{}} = RoleAPI.delete_role(role)
    assert_raise Ecto.NoResultsError, fn -> RoleAPI.get_role!(role.id) end
  end

  test "change_role/1 returns a role changeset" do
    role = fixture(:role)
    assert %Ecto.Changeset{} = RoleAPI.change_role(role)
  end
end
