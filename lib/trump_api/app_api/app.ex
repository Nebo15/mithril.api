defmodule Trump.AppAPI.App do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "apps" do
    field :scope, :string
    field :user_id, :binary_id
    field :client_id, :binary_id

    timestamps()
  end
end
