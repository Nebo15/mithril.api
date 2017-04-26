defmodule Trump.ClientTypeAPI.ClientType do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "client_types" do
    field :name, :string
    field :scope, :string

    timestamps()
  end
end
