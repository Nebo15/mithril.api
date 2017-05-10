defmodule Mithril.Web.UserAPITest do
  use Mithril.DataCase

  alias Mithril.Web.UserAPI
  alias Mithril.Web.UserAPI.User

  @create_attrs %{email: "some email", password: "some password", settings: %{}}
  @update_attrs %{email: "some updated email", password: "some updated password", settings: %{}}
  @invalid_attrs %{email: nil, password: nil, settings: nil}

  def fixture(:user, attrs \\ @create_attrs) do
    {:ok, user} = UserAPI.create_user(attrs)
    user
  end

  test "list_users/1 returns all users without search params" do
    user = fixture(:user)
    paging = %Ecto.Paging{cursors: %Ecto.Paging.Cursors{starting_after: user.id}, has_more: false}
    assert UserAPI.list_users(%{}) == {[user], paging}
  end

  test "list_users/1 returns all users with valid search params" do
    user = fixture(:user)
    paging = %Ecto.Paging{cursors: %Ecto.Paging.Cursors{starting_after: user.id}, has_more: false}
    assert UserAPI.list_users(%{email: user.email}) == {[user], paging}
  end

  test "list_users/1 returns empty list with invalid search params" do
    user = fixture(:user)
    paging = %Ecto.Paging{has_more: false}
    assert UserAPI.list_users(%{email: user.email <> "111"}) == {[], paging}
  end

  test "get_user! returns the user with given id" do
    user = fixture(:user)
    assert UserAPI.get_user!(user.id) == user
  end

  test "create_user/1 with valid data creates a user" do
    assert {:ok, %User{} = user} = UserAPI.create_user(@create_attrs)
    assert user.email == "some email"
    assert user.password == "some password"
    assert user.settings == %{}
  end

  test "create_user/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = UserAPI.create_user(@invalid_attrs)
  end

  test "update_user/2 with valid data updates the user" do
    user = fixture(:user)
    assert {:ok, user} = UserAPI.update_user(user, @update_attrs)
    assert %User{} = user
    assert user.email == "some updated email"
    assert user.password == "some updated password"
    assert user.settings == %{}
  end

  test "update_user/2 with invalid data returns error changeset" do
    user = fixture(:user)
    assert {:error, %Ecto.Changeset{}} = UserAPI.update_user(user, @invalid_attrs)
    assert user == UserAPI.get_user!(user.id)
  end

  test "delete_user/1 deletes the user" do
    user = fixture(:user)
    assert {:ok, %User{}} = UserAPI.delete_user(user)
    assert_raise Ecto.NoResultsError, fn -> UserAPI.get_user!(user.id) end
  end

  test "change_user/1 returns a user changeset" do
    user = fixture(:user)
    assert %Ecto.Changeset{} = UserAPI.change_user(user)
  end
end
