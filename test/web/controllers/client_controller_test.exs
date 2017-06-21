defmodule Mithril.Web.ClientControllerTest do
  use Mithril.Web.ConnCase

  alias Ecto.UUID
  alias Mithril.ClientAPI
  alias Mithril.ClientAPI.Client

  @update_attrs %{
    name: "some updated name",
    priv_settings: %{},
    redirect_uri: "https://localhost",
    secret: "some updated secret",
    settings: %{}
  }

  @invalid_attrs %{
    name: nil,
    priv_settings: nil,
    redirect_uri: nil,
    settings: nil
  }

  def fixture(:client) do
    attrs = Mithril.Fixtures.client_create_attrs()
    {:ok, client} = ClientAPI.create_client(attrs)
    client
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    fixture(:client)
    fixture(:client)
    fixture(:client)
    conn = get conn, client_path(conn, :index)
    assert 3 == length(json_response(conn, 200)["data"])
  end

  test "does not list all entries on index when limit is set", %{conn: conn} do
    fixture(:client)
    fixture(:client)
    fixture(:client)
    conn = get conn, client_path(conn, :index), %{limit: 2}
    assert 2 == length(json_response(conn, 200)["data"])
  end

  test "does not list all entries on index when starting_after is set", %{conn: conn} do
    client = fixture(:client)
    fixture(:client)
    fixture(:client)
    conn = get conn, client_path(conn, :index), %{starting_after: client.id}
    assert 2 == length(json_response(conn, 200)["data"])
  end

  test "does not list all entries on index when ending_before is set", %{conn: conn} do
    fixture(:client)
    fixture(:client)
    client = fixture(:client)
    conn = get conn, client_path(conn, :index), %{ending_before: client.id}
    assert 2 == length(json_response(conn, 200)["data"])
  end

  test "search clients by name", %{conn: conn} do
    name = "search_name"
    fixture(:client)
    {:ok, _} = name |> Mithril.Fixtures.client_create_attrs() |> ClientAPI.create_client()

    conn = get conn, client_path(conn, :index, [name: name])
    resp = json_response(conn, 200)

    assert Map.has_key?(resp, "paging")
    assert 1 == length(resp["data"])
    refute resp["paging"]["has_more"]
  end

  test "show client details", %{conn: conn} do
    client = fixture(:client)

    conn = get conn, client_details_path(conn, :details, client.id)
    assert json_response(conn, 200)["data"] == %{
      "id" => client.id,
      "name" => client.name,
      "settings" => client.settings,
      "redirect_uri" => client.redirect_uri,
      "client_type_name" => "some_kind_of_client"
    }
  end

  test "creates client and renders client when data is valid", %{conn: conn} do
    attrs = Mithril.Fixtures.client_create_attrs()
    conn = post conn, client_path(conn, :create), client: attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    name = attrs.name
    conn = get conn, client_path(conn, :show, id)
    assert %{
      "id" => id,
      "name" => name,
      "secret" => _,
      "settings" => %{},
      "priv_settings" => %{},
      "redirect_uri" => "http://localhost"
    } = json_response(conn, 200)["data"]
  end

  test "does not create client and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, client_path(conn, :create), client: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "put new client with id", %{conn: conn} do
    %Client{client_type_id: client_type_id, user_id: user_id} = fixture(:client)

    update_attrs = Map.merge(@update_attrs, %{
      client_type_id: client_type_id,
      user_id: user_id
    })

    id = UUID.generate()
    conn = put conn, client_path(conn, :update, %Client{id: id}), client: update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, client_path(conn, :show, id)
    assert %{"id" => ^id} = json_response(conn, 200)["data"]
  end

  test "updates chosen client and renders client when data is valid", %{conn: conn} do
    %Client{id: id} = client = fixture(:client)
    conn = put conn, client_path(conn, :update, client), client: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, client_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some updated name",
      "priv_settings" => %{},
      "redirect_uri" => "https://localhost",
      "secret" => client.secret,
      "settings" => %{},
    }
  end

  test "does not update chosen client and renders errors when data is invalid", %{conn: conn} do
    client = fixture(:client)
    conn = put conn, client_path(conn, :update, client), client: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen client", %{conn: conn} do
    client = fixture(:client)
    conn = delete conn, client_path(conn, :delete, client)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, client_path(conn, :show, client)
    end
  end
end
