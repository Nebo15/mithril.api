defmodule Mithril.AppAPI do
  @moduledoc """
  The boundary for the AppAPI system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Mithril.Repo

  alias Mithril.AppAPI.App

  def list_apps do
    Repo.all(App)
  end

  def get_app!(id), do: Repo.get!(App, id)

  def get_app_by!(attrs), do: Repo.get_by!(App, attrs)

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

  def change_app(%App{} = app) do
    app_changeset(app, %{})
  end

  # TODO: add constraint validations
  defp app_changeset(%App{} = app, attrs) do
    app
    |> cast(attrs, [:user_id, :client_id, :scope])
    |> validate_required([:user_id, :client_id, :scope])
  end
end
