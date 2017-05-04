defmodule Mithril.ClientAPI do
  @moduledoc false

  import Ecto.{Query, Changeset}, warn: false
  alias Mithril.Repo

  alias Mithril.ClientAPI.Client
  alias Authable.Utils.Crypt, as: CryptUtil

  def list_clients do
    Repo.all(Client)
  end

  def get_client!(id), do: Repo.get!(Client, id)

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

  defp client_changeset(%Client{} = client, attrs) do
    client
    |> cast(attrs, [:name, :secret, :redirect_uri, :settings, :priv_settings, :client_type_id])
    |> put_secret()
    |> validate_required([:name, :secret, :redirect_uri, :settings, :priv_settings])
  end

  defp put_secret(changeset) do
    case fetch_field(changeset, :secret) do
      {:data, nil} ->
        put_change(changeset, :secret, CryptUtil.generate_token)
      _ ->
        changeset
    end
  end
end
