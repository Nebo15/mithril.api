defmodule Mithril.RoleAPI.RoleSearch do
  @moduledoc false

  use Ecto.Schema

  schema "role_search" do
    field :name, :string
  end
end
