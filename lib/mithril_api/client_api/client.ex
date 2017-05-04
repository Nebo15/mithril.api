defmodule Mithril.ClientAPI.Client do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "clients" do
    field :name, :string
    field :priv_settings, :map, default: %{}
    field :redirect_uri, :string
    field :secret, :string
    field :settings, :map, default: %{}
    field :client_type_id, :binary_id, virtual: true

    belongs_to :user, Mithril.Web.UserAPI.User

    timestamps()
  end
end
