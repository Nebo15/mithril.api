defmodule Mithril.Repo.Migrations.MakeOtherScopeFieldsBigger do
  use Ecto.Migration

  def change do
    alter table(:roles) do
      modify :scope, :string, size: 2048
    end

    alter table(:client_types) do
      modify :scope, :string, size: 2048
    end
  end
end
