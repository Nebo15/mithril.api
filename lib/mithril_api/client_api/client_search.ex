defmodule Mithril.ClientAPI.ClientSearch do
  @moduledoc false

  use Ecto.Schema

  schema "employee_search" do
    field :name, :string
    field :user_id, Ecto.UUID
  end
end
