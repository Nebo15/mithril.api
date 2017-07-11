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

  def get_client_with_type(id) do
    query =
      from c in Client,
        left_join: ct in assoc(c, :client_type), on: ct.id == c.client_type_id,
        where: c.id == ^id,
        preload: [client_type: ct]

    Repo.one(query)
  end

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
    Repo.insert(changeset)
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
    client
    |> cast(attrs, [:name, :user_id])
    |> set_like_attributes([:name])
  end
  defp client_changeset(%Client{} = client, attrs) do
    client
    |> cast(attrs, [:name, :user_id, :redirect_uri, :settings, :priv_settings, :client_type_id])
    |> put_secret()
    |> validate_required([:name, :user_id, :redirect_uri, :settings, :priv_settings, :client_type_id])
    |> validate_format(:redirect_uri, ~r{^https?://.+})
    |> unique_constraint(:name)
    |> assoc_constraint(:user)
    |> assoc_constraint(:client_type)
  end

  defp put_secret(changeset) do
    case fetch_field(changeset, :secret) do
      {:data, nil} ->
        put_change(changeset, :secret, SecureRandom.urlsafe_base64)
      _ ->
        changeset
    end
  end
end
