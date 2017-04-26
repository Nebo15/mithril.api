defmodule Mithril.ClientAPI do
  @moduledoc """
  The boundary for the ClientAPI system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Mithril.Repo

  alias Mithril.ClientAPI.Client

  @doc """
  Returns the list of clients.

  ## Examples

      iex> list_clients()
      [%Client{}, ...]

  """
  def list_clients do
    Repo.all(Client)
  end

  @doc """
  Gets a single client.

  Raises `Ecto.NoResultsError` if the Client does not exist.

  ## Examples

      iex> get_client!(123)
      %Client{}

      iex> get_client!(456)
      ** (Ecto.NoResultsError)

  """
  def get_client!(id), do: Repo.get!(Client, id)

  @doc """
  Creates a client.

  ## Examples

      iex> create_client(%{field: value})
      {:ok, %Client{}}

      iex> create_client(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_client(attrs \\ %{}) do
    changeset = client_changeset(%Client{}, attrs)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:client, changeset)
      |> Ecto.Multi.run(:client_type, fn %{client: client} ->
           id =
             Ecto.UUID.generate()
             |> Ecto.UUID.dump()
             |> elem(1)

           client_id =
             client.id
             |> Ecto.UUID.dump()
             |> elem(1)

           client_type_id =
             changeset.changes.client_type_id
             |> Ecto.UUID.dump()
             |> elem(1)

           record = [
             id:             id,
             client_id:      client_id,
             client_type_id: client_type_id,
             inserted_at:    DateTime.utc_now(),
             updated_at:     DateTime.utc_now()
           ]

           case Repo.insert_all("client_client_types", [record]) do
             {n, _} ->
               {:ok, :client_type}
             _ ->
               {:error, :error}
           end
         end)
      |> Repo.transaction()

    case result do
      {:ok, %{client: client}} ->
        {:ok, client}
      {:error, :client, data, _} ->
        {:error, data}
    end
  end

  @doc """
  Updates a client.

  ## Examples

      iex> update_client(client, %{field: new_value})
      {:ok, %Client{}}

      iex> update_client(client, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_client(%Client{} = client, attrs) do
    client
    |> client_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Client.

  ## Examples

      iex> delete_client(client)
      {:ok, %Client{}}

      iex> delete_client(client)
      {:error, %Ecto.Changeset{}}

  """
  def delete_client(%Client{} = client) do
    Repo.delete(client)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking client changes.

  ## Examples

      iex> change_client(client)
      %Ecto.Changeset{source: %Client{}}

  """
  def change_client(%Client{} = client) do
    client_changeset(client, %{})
  end

  defp client_changeset(%Client{} = client, attrs) do
    client
    |> cast(attrs, [:name, :secret, :redirect_uri, :settings, :priv_settings, :client_type_id])
    |> validate_required([:name, :secret, :redirect_uri, :settings, :priv_settings])
  end
end
