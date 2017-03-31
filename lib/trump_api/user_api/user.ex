defmodule Trump.Web.UserAPI.User do
  @moduledoc false

  use Ecto.Schema

  schema "user_api_users" do
    field :email, :string
    field :password, :string
    field :scopes, {:array, :string}

    timestamps()
  end
end
