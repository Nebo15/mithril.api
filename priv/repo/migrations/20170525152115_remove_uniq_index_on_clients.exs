defmodule Mithril.Repo.Migrations.RemoveUniqIndexOnClients do
  use Ecto.Migration

  def up do
    drop index(:clients, [:name])
  end

  def down do
    create unique_index(:clients, [:name])
  end
end
