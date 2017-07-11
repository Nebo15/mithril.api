defmodule Mithril.TokenAPI.TokenSearch do
  @moduledoc false

  use Ecto.Schema

  schema "token_search" do
    field :name, :string
    field :value, :string
    field :user_id, Ecto.UUID
    field :client_id, Ecto.UUID
  end
end
