defmodule Mithril.UserRoleAPI.UserRoleSearch do
  @moduledoc false

  use Ecto.Schema

  schema "user_role_search" do
    field :role_id, Ecto.UUID
    field :user_id, Ecto.UUID
    field :client_id, Ecto.UUID
  end
end
