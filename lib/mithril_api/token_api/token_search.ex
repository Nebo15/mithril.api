defmodule Mithril.TokenAPI.TokenSearch do
  @moduledoc false

  use Ecto.Schema

  schema "token_search" do
    field :name, :string
    field :value, :string
    field :user_id, :binary_id
    embeds_one :details, Details do
      field :client_id, :string
    end
  end
end
