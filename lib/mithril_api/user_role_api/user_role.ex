defmodule Mithril.UserRoleAPI.UserRole do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_roles" do
    field :client_id, :binary_id
    # field :role_id, :binary_id
    field :user_id, :binary_id

    belongs_to :role, Mithril.RoleAPI.Role

    timestamps()
  end
end
