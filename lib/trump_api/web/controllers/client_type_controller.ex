defmodule Trump.Web.ClientTypeController do
  use Trump.Web, :controller

  alias Trump.ClientTypeAPI
  alias Trump.ClientTypeAPI.ClientType

  action_fallback Trump.Web.FallbackController

  def index(conn, _params) do
    client_types = ClientTypeAPI.list_client_types()
    render(conn, "index.json", client_types: client_types)
  end

  def create(conn, %{"client_type" => client_type_params}) do
    with {:ok, %ClientType{} = client_type} <- ClientTypeAPI.create_client_type(client_type_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", client_type_path(conn, :show, client_type))
      |> render("show.json", client_type: client_type)
    end
  end

  def show(conn, %{"id" => id}) do
    client_type = ClientTypeAPI.get_client_type!(id)
    render(conn, "show.json", client_type: client_type)
  end

  def update(conn, %{"id" => id, "client_type" => client_type_params}) do
    client_type = ClientTypeAPI.get_client_type!(id)

    with {:ok, %ClientType{} = client_type} <- ClientTypeAPI.update_client_type(client_type, client_type_params) do
      render(conn, "show.json", client_type: client_type)
    end
  end

  def delete(conn, %{"id" => id}) do
    client_type = ClientTypeAPI.get_client_type!(id)
    with {:ok, %ClientType{}} <- ClientTypeAPI.delete_client_type(client_type) do
      send_resp(conn, :no_content, "")
    end
  end
end
