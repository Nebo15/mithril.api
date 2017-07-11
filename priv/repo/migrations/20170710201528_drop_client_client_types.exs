defmodule Mithril.Repo.Migrations.DropClientClientTypes do
  use Ecto.Migration

  def change do
    alter table(:clients) do
      add :client_type_id, :uuid
    end

    # Migrates data from client_client_types to client.client_type_id
    sql = """
    UPDATE clients
    SET client_type_id = subquery.client_type_id
    FROM (
      SELECT client_type_id, client_id
      FROM client_client_types
    ) AS subquery
    WHERE clients.id = subquery.client_id
    """

    execute sql

    alter table(:clients) do
      modify :client_type_id, references(:client_types, type: :uuid), null: false
    end

    drop table(:client_client_types)
  end
end
