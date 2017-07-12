defmodule Mithril.ClientAPI.ClientTypeSearch do
  @moduledoc false

  use Ecto.Schema

  schema "client_type_search" do
    field :name, :string
    field :scope, :string
  end
end
