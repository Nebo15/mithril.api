defmodule Trump.Web.UserAPI.User do
  @moduledoc false

  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :email, :string
    field :password, :string
    field :scopes, {:array, :string}

    timestamps()
  end
end
