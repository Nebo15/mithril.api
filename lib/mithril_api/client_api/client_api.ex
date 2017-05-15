defmodule Mithril.ClientAPI do
  @moduledoc false

  use Mithril.Search

  import Ecto.{Query, Changeset}, warn: false
  alias Mithril.Repo

  alias Mithril.ClientAPI.Client
  alias Mithril.ClientAPI.ClientSearch

  def list_clients(params) do
    %ClientSearch{}
    |> client_changeset(params)
    |> search(params, Client, 50)
  end

  def get_client!(id), do: Repo.get!(Client, id)
  def get_client(id), do: Repo.get(Client, id)

  def get_client_by(attrs), do: Repo.get_by(Client, attrs)


  def edit_client(id, attrs \\ %{}) do
    case Repo.get(Client, id) do
      nil                -> create_client(id, attrs)
      %Client{} = client -> update_client(client, attrs)
    end
  end

  def create_client do
    %Client{}
    |> client_changeset(%{})
    |> create_client()
  end

  def create_client(id, attrs) do
    %Client{id: id}
    |> client_changeset(attrs)
    |> create_client()
  end

  def create_client(%Ecto.Changeset{} = changeset) do
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
             {_n, _} ->
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

  def create_client(attrs) when is_map(attrs) do
    %Client{}
    |> client_changeset(attrs)
    |> create_client()
  end

  def update_client(%Client{} = client, attrs) do
    client
    |> client_changeset(attrs)
    |> Repo.update()
  end

  def delete_client(%Client{} = client) do
    Repo.delete(client)
  end

  def change_client(%Client{} = client) do
    client_changeset(client, %{})
  end

  defp client_changeset(%ClientSearch{} = client, attrs) do
    fields = ~W(
      name
      user_id
    )

    cast(client, attrs, fields)
  end
  defp client_changeset(%Client{} = client, attrs) do
    client
    |> cast(attrs, [:name, :user_id, :redirect_uri, :settings, :priv_settings, :client_type_id])
    |> put_secret()
    |> validate_required([:name, :user_id, :redirect_uri, :settings, :priv_settings])
    |> validate_client_type()
    |> unique_constraint(:name)
    |> assoc_constraint(:user)
  end

  defp put_secret(changeset) do
    case fetch_field(changeset, :secret) do
      {:data, nil} ->
        put_change(changeset, :secret, SecureRandom.urlsafe_base64)
      _ ->
        changeset
    end
  end

  defp validate_client_type(changeset) do
    case fetch_field(changeset, :id) do
      {:data, nil} ->
        validate_required(changeset, [:client_type_id])
      {:data, _} ->
        changeset
    end
  end
end
