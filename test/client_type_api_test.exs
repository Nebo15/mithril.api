defmodule Mithril.ClientTypeAPITest do
  use Mithril.DataCase

  alias Mithril.ClientTypeAPI
  alias Mithril.ClientTypeAPI.ClientType

  @create_attrs %{name: "some name", scope: "some scope"}
  @update_attrs %{name: "some updated name", scope: "some updated scope"}
  @invalid_attrs %{name: nil, scope: nil}

  def fixture(:client_type, attrs \\ @create_attrs) do
    {:ok, client_type} = ClientTypeAPI.create_client_type(attrs)
    client_type
  end

  test "list_client_types/1 returns all client_types" do
    client_type = fixture(:client_type)
    {client_types, _paging} = ClientTypeAPI.list_client_types()
    assert [client_type] == client_types
  end

  test "get_client_type! returns the client_type with given id" do
    client_type = fixture(:client_type)
    assert ClientTypeAPI.get_client_type!(client_type.id) == client_type
  end

  test "create_client_type/1 with valid data creates a client_type" do
    assert {:ok, %ClientType{} = client_type} = ClientTypeAPI.create_client_type(@create_attrs)
    assert client_type.name == "some name"
    assert client_type.scope == "some scope"
  end

  test "create_client_type/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = ClientTypeAPI.create_client_type(@invalid_attrs)
  end

  test "update_client_type/2 with valid data updates the client_type" do
    client_type = fixture(:client_type)
    assert {:ok, client_type} = ClientTypeAPI.update_client_type(client_type, @update_attrs)
    assert %ClientType{} = client_type
    assert client_type.name == "some updated name"
    assert client_type.scope == "some updated scope"
  end

  test "update_client_type/2 with invalid data returns error changeset" do
    client_type = fixture(:client_type)
    assert {:error, %Ecto.Changeset{}} = ClientTypeAPI.update_client_type(client_type, @invalid_attrs)
    assert client_type == ClientTypeAPI.get_client_type!(client_type.id)
  end

  test "delete_client_type/1 deletes the client_type" do
    client_type = fixture(:client_type)
    assert {:ok, %ClientType{}} = ClientTypeAPI.delete_client_type(client_type)
    assert_raise Ecto.NoResultsError, fn -> ClientTypeAPI.get_client_type!(client_type.id) end
  end

  test "change_client_type/1 returns a client_type changeset" do
    client_type = fixture(:client_type)
    assert %Ecto.Changeset{} = ClientTypeAPI.change_client_type(client_type)
  end
end
