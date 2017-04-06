defmodule Trump.TokenAPITest do
  use Trump.DataCase

  alias Trump.TokenAPI
  alias Trump.TokenAPI.Token

  @create_attrs %{
    details: %{},
    expires_at: 42,
    name: "some name",
    value: "some value"
  }

  @update_attrs %{
    details: %{},
    expires_at: 43,
    name: "some updated name",
    value: "some updated value"
  }

  @invalid_attrs %{
    details: nil,
    expires_at: nil,
    name: nil,
    value: nil
  }

  def fixture(:token, attrs \\ @create_attrs) do
    {:ok, token} = TokenAPI.create_token(attrs)
    token
  end

  test "list_tokens/1 returns all tokens" do
    token = fixture(:token)
    assert TokenAPI.list_tokens() == [token]
  end

  test "get_token! returns the token with given id" do
    token = fixture(:token)
    assert TokenAPI.get_token!(token.id) == token
  end

  test "create_token/1 with valid data creates a token" do
    assert {:ok, %Token{} = token} = TokenAPI.create_token(@create_attrs)
    assert token.details == %{}
    assert token.expires_at == 42
    assert token.name == "some name"
    assert token.value == "some value"
  end

  test "create_token/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = TokenAPI.create_token(@invalid_attrs)
  end

  test "update_token/2 with valid data updates the token" do
    token = fixture(:token)
    assert {:ok, token} = TokenAPI.update_token(token, @update_attrs)
    assert %Token{} = token
    assert token.details == %{}
    assert token.expires_at == 43
    assert token.name == "some updated name"
    assert token.value == "some updated value"
  end

  test "update_token/2 with invalid data returns error changeset" do
    token = fixture(:token)
    assert {:error, %Ecto.Changeset{}} = TokenAPI.update_token(token, @invalid_attrs)
    assert token == TokenAPI.get_token!(token.id)
  end

  test "delete_token/1 deletes the token" do
    token = fixture(:token)
    assert {:ok, %Token{}} = TokenAPI.delete_token(token)
    assert_raise Ecto.NoResultsError, fn -> TokenAPI.get_token!(token.id) end
  end

  test "change_token/1 returns a token changeset" do
    token = fixture(:token)
    assert %Ecto.Changeset{} = TokenAPI.change_token(token)
  end
end
