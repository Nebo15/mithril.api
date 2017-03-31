defmodule Trump.Web.UserAPITest do
  use Trump.DataCase

  alias Trump.Web.UserAPI
  alias Trump.Web.UserAPI.User

  @create_attrs %{email: "some email", password: "some password", scopes: []}
  @update_attrs %{email: "some updated email", password: "some updated password", scopes: []}
  @invalid_attrs %{email: nil, password: nil, scopes: nil}

  def fixture(:user, attrs \\ @create_attrs) do
    {:ok, user} = Web.UserAPI.create_user(attrs)
    user
  end

  test "list_users/1 returns all users" do
    user = fixture(:user)
    assert Web.UserAPI.list_users() == [user]
  end

  test "get_user! returns the user with given id" do
    user = fixture(:user)
    assert Web.UserAPI.get_user!(user.id) == user
  end

  test "create_user/1 with valid data creates a user" do
    assert {:ok, %User{} = user} = Web.UserAPI.create_user(@create_attrs)
    assert user.email == "some email"
    assert user.password == "some password"
    assert user.scopes == []
  end

  test "create_user/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Web.UserAPI.create_user(@invalid_attrs)
  end

  test "update_user/2 with valid data updates the user" do
    user = fixture(:user)
    assert {:ok, user} = Web.UserAPI.update_user(user, @update_attrs)
    assert %User{} = user
    assert user.email == "some updated email"
    assert user.password == "some updated password"
    assert user.scopes == []
  end

  test "update_user/2 with invalid data returns error changeset" do
    user = fixture(:user)
    assert {:error, %Ecto.Changeset{}} = Web.UserAPI.update_user(user, @invalid_attrs)
    assert user == Web.UserAPI.get_user!(user.id)
  end

  test "delete_user/1 deletes the user" do
    user = fixture(:user)
    assert {:ok, %User{}} = Web.UserAPI.delete_user(user)
    assert_raise Ecto.NoResultsError, fn -> Web.UserAPI.get_user!(user.id) end
  end

  test "change_user/1 returns a user changeset" do
    user = fixture(:user)
    assert %Ecto.Changeset{} = Web.UserAPI.change_user(user)
  end
end
