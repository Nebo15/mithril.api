defmodule Trump.ClientAPI.Client do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "clients" do
    field :name, :string
    field :priv_settings, :map
    field :redirect_uri, :string
    field :secret, :string
    field :settings, :map
    field :user_id, :binary_id

    timestamps()
  end
end
