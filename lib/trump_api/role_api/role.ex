defmodule Trump.RoleAPI.Role do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "roles" do
    field :name, :string
    field :scope, :string

    timestamps()
  end
end
