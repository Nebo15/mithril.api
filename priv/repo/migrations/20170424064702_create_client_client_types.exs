defmodule Trump.Repo.Migrations.CreateClientClientTypes do
  use Ecto.Migration

  def change do
    create table(:client_client_types, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :client_id, references(:clients, on_delete: :delete_all, type: :uuid)
      add :client_type_id, references(:client_types, on_delete: :delete_all, type: :uuid)

      timestamps()
    end

    create unique_index(:client_client_types, [:client_id, :client_type_id])
  end
end
