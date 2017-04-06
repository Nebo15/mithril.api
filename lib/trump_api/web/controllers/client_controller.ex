defmodule Trump.Web.ClientController do
  use Trump.Web, :controller

  alias Trump.ClientAPI
  alias Trump.ClientAPI.Client

  action_fallback Trump.Web.FallbackController

  def index(conn, _params) do
    clients = ClientAPI.list_clients()
    render(conn, "index.json", clients: clients)
  end

  def create(conn, %{"client" => client_params}) do
    with {:ok, %Client{} = client} <- ClientAPI.create_client(client_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", client_path(conn, :show, client))
      |> render("show.json", client: client)
    end
  end

  def show(conn, %{"id" => id}) do
    client = ClientAPI.get_client!(id)
    render(conn, "show.json", client: client)
  end

  def update(conn, %{"id" => id, "client" => client_params}) do
    client = ClientAPI.get_client!(id)

    with {:ok, %Client{} = client} <- ClientAPI.update_client(client, client_params) do
      render(conn, "show.json", client: client)
    end
  end

  def delete(conn, %{"id" => id}) do
    client = ClientAPI.get_client!(id)
    with {:ok, %Client{}} <- ClientAPI.delete_client(client) do
      send_resp(conn, :no_content, "")
    end
  end
end
