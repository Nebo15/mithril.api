defmodule Trump.Repo.Migrations.CreateApp do
  use Ecto.Migration

  def change do
    create table(:apps, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :scope, :string
      add :user_id, references(:users, on_delete: :delete_all, type: :uuid)
      add :client_id, references(:clients, on_delete: :delete_all, type: :uuid)

      timestamps()
    end

    create unique_index(:apps, [:user_id, :client_id])
  end
end
