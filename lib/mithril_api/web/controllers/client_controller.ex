defmodule Mithril.Web.ClientController do
  use Mithril.Web, :controller

  alias Mithril.ClientAPI
  alias Mithril.ClientAPI.Client

  action_fallback Mithril.Web.FallbackController

  def index(conn, params) do
    with {clients, %Ecto.Paging{} = paging} <- ClientAPI.list_clients(params) do
      render(conn, "index.json", clients: clients, paging: paging, render_secret: true)
    end
  end

  def create(conn, %{"client" => client_params}) do
    with {:ok, %Client{} = client} <- ClientAPI.create_client(client_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", client_path(conn, :show, client))
      |> render("show.json", client: client, render_secret: true)
    end
  end

  def show(conn, %{"id" => id}) do
    client = ClientAPI.get_client!(id)
    render(conn, "show.json", client: client, render_secret: false)
  end

  def update(conn, %{"id" => id, "client" => client_params}) do
    with {:ok, %Client{} = client} <- ClientAPI.edit_client(id, client_params) do
      render(conn, "show.json", client: client, render_secret: false)
    end
  end

  def delete(conn, %{"id" => id}) do
    client = ClientAPI.get_client!(id)
    with {:ok, %Client{}} <- ClientAPI.delete_client(client) do
      send_resp(conn, :no_content, "")
    end
  end
end
