defmodule Trump.Web.Repo.Migrations.CreateTrump.Web.UserAPI.User do
  use Ecto.Migration

  def change do
    create table(:user_api_users) do
      add :email, :string
      add :password, :string
      add :scopes, {:array, :string}

      timestamps()
    end

  end
end
