defmodule Mithril.Web.UserAPI.User do
  @moduledoc false

  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :email, :string
    field :password, :string
    field :settings, :map, default: %{}
    field :priv_settings, :map, default: %{}

    has_many :user_roles, Mithril.UserRoleAPI.UserRole
    has_many :roles, through: [:user_roles, :role]

    timestamps()
  end
end
