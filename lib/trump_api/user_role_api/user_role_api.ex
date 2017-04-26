defmodule Trump.UserRoleAPI do
  @moduledoc """
  The boundary for the UserRoleAPI system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Trump.Repo

  alias Trump.UserRoleAPI.UserRole

  def list_user_roles(user_id) do
    query =
      from ur in UserRole, where: ur.user_id == ^user_id

    Repo.all(query)
  end

  def get_user_role!(id), do: Repo.get!(UserRole, id) # get_by

  def create_user_role(attrs \\ %{}) do
    %UserRole{}
    |> user_role_changeset(attrs)
    |> Repo.insert()
  end

  def delete_user_role(%UserRole{} = user_role) do
    Repo.delete(user_role)
  end

  defp user_role_changeset(%UserRole{} = user_role, attrs) do
    user_role
    |> cast(attrs, [:user_id, :role_id, :client_id])
    |> validate_required([:user_id, :role_id, :client_id])
  end
end
