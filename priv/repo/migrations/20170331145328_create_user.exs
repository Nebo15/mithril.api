defmodule Trump.Web.Repo.Migrations.CreateTrump.Web.UserAPI.User do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :password, :string
      add :scopes, {:array, :string}

      timestamps()
    end

  end
end
