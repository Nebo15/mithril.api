defmodule Mithril.ClientAPI.Client do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "clients" do
    field :name, :string
    field :priv_settings, :map, default: %{}
    field :redirect_uri, :string, default: "fill_me"
    field :secret, :string
    field :settings, :map, default: %{}
    field :user_id, :binary_id
    field :client_type_id, :binary_id, virtual: true

    timestamps()
  end
end
