defmodule Mithril.Repo.Migrations.MakeAppScopeFieldBigger do
  use Ecto.Migration

  def change do
    alter table(:apps) do
      modify :scope, :string, size: 2048
    end
  end
end
