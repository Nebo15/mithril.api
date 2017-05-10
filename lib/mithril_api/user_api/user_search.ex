defmodule Mithril.Web.UserAPI.UserSearch do
  @moduledoc false

  use Ecto.Schema

  schema "user_search" do
    field :email, :string
  end
end
