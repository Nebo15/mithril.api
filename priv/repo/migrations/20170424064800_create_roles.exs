defmodule Trump.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :scope, :string

      timestamps()
    end
  end
end
