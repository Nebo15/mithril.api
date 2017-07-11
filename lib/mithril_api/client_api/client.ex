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

    belongs_to :client_type, Mithril.ClientTypeAPI.ClientType
    # TODO: Remove Web prefix
    belongs_to :user, Mithril.Web.UserAPI.User

    timestamps()
  end
end
