defmodule Mithril.AppAPI do
  @moduledoc """
  The boundary for the AppAPI system.
  """
  use Mithril.Search
  import Ecto.{Query, Changeset}, warn: false

  alias Mithril.Paging
  alias Mithril.Repo
  alias Mithril.AppAPI.App
  alias Mithril.AppAPI.AppSearch

  def list_apps(params) do
    %AppSearch{}
    |> app_changeset(params)
    |> search(params, App, 50)
  end

  def get_app!(id), do: Repo.get!(App, id)

  def get_app_by(attrs), do: Repo.get_by(App, attrs)

  def create_app(attrs \\ %{}) do
    %App{}
    |> app_changeset(attrs)
    |> Repo.insert()
  end

  def update_app(%App{} = app, attrs) do
    app
    |> app_changeset(attrs)
    |> Repo.update()
  end

  def delete_app(%App{} = app) do
    Repo.delete(app)
  end

  def delete_apps_by_params(params) do
    %AppSearch{}
    |> app_changeset(params)
    |> case do
         %Ecto.Changeset{valid?: true, changes: changes} ->
           App |> get_search_query(changes) |> Repo.delete_all()

         changeset
          -> changeset
       end
  end

  def change_app(%App{} = app) do
    app_changeset(app, %{})
  end

  def approval(user_id, client_id) do
    get_app_by(user_id: user_id, client_id: client_id)
  end

  defp app_changeset(%App{} = app, attrs) do
    app
    |> cast(attrs, [:user_id, :client_id, :scope])
    |> unique_constraint(:user_id, name: "apps_user_id_client_id_index")
    |> validate_required([:user_id, :client_id, :scope])
  end

  defp app_changeset(%AppSearch{} = app, attrs) do
    cast(app, attrs, [:user_id, :client_id])
  end
end
