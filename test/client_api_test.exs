defmodule Trump.ClientAPITest do
  use Trump.DataCase

  alias Trump.ClientAPI
  alias Trump.ClientAPI.Client

  @update_attrs %{
    name: "some updated name",
    priv_settings: %{},
    redirect_uri: "some updated redirect_uri",
    secret: "some updated secret",
    settings: %{}
  }

  @invalid_attrs %{
    name: nil,
    priv_settings: nil,
    redirect_uri: nil,
    secret: nil,
    settings: nil
  }

  def fixture(:client) do
    attrs = Trump.Fixtures.client_create_attrs()
    {:ok, client} = ClientAPI.create_client(attrs)
    client
  end

  test "list_clients/1 returns all clients" do
    client = fixture(:client)
    assert ClientAPI.list_clients() == [%{client | client_type_id: nil}]
  end

  test "get_client! returns the client with given id" do
    client = fixture(:client)
    assert ClientAPI.get_client!(client.id) == %{client | client_type_id: nil}
  end

  test "create_client/1 with valid data creates a client" do
    attrs = Trump.Fixtures.client_create_attrs()
    assert {:ok, %Client{} = client} = ClientAPI.create_client(attrs)
    assert client.name == "some name"
    assert client.priv_settings == %{}
    assert client.redirect_uri == "some redirect_uri"
    assert client.secret == "some secret"
    assert client.settings == %{}
  end

  test "create_client/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = ClientAPI.create_client(@invalid_attrs)
  end

  test "update_client/2 with valid data updates the client" do
    client = fixture(:client)
    assert {:ok, client} = ClientAPI.update_client(client, @update_attrs)
    assert %Client{} = client
    assert client.name == "some updated name"
    assert client.priv_settings == %{}
    assert client.redirect_uri == "some updated redirect_uri"
    assert client.secret == "some updated secret"
    assert client.settings == %{}
  end

  test "update_client/2 with invalid data returns error changeset" do
    client = fixture(:client)
    assert {:error, %Ecto.Changeset{}} = ClientAPI.update_client(client, @invalid_attrs)
    assert %{client | client_type_id: nil} == ClientAPI.get_client!(client.id)
  end

  test "delete_client/1 deletes the client" do
    client = fixture(:client)
    assert {:ok, %Client{}} = ClientAPI.delete_client(client)
    assert_raise Ecto.NoResultsError, fn -> ClientAPI.get_client!(client.id) end
  end

  test "change_client/1 returns a client changeset" do
    client = fixture(:client)
    assert %Ecto.Changeset{} = ClientAPI.change_client(client)
  end
end
