defmodule Mithril.AppAPI.AppSearch do
  @moduledoc false

  use Ecto.Schema

  schema "app_search" do
    field :user_id, :string
    field :client_id, :string
  end
end
