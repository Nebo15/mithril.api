defmodule Trump.TokenAPI.Token do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tokens" do
    field :details, :map
    field :expires_at, :integer
    field :name, :string
    field :value, :string
    field :user_id, :binary_id

    timestamps()
  end
end
