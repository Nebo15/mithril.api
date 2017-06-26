defmodule Mithril.TokenAPI.TokenSearch do
  @moduledoc false

  use Ecto.Schema

  schema "token_search" do
    field :name, :string
    field :value, :string
    field :user_id, :binary_id
  end
end
