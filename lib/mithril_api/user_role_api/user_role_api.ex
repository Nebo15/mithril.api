defmodule Mithril.UserRoleAPI do
  @moduledoc """
  The boundary for the UserRoleAPI system.
  """
  use Mithril.Search

  import Ecto.{Query, Changeset}, warn: false

  alias Mithril.Repo
  alias Mithril.RoleAPI.Role
  alias Mithril.UserRoleAPI.UserRole
  alias Mithril.UserRoleAPI.UserRoleSearch

  def list_user_roles(params \\ %{}) do
    %UserRoleSearch{}
    |> user_role_changeset(params)
    |> search(params, UserRole, 50)
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

  def delete_user_roles_by_params(%{"user_id" => user_id, "role_name" => role_name}) do
    query = from u in UserRole,
      inner_join: r in Role, on: [id: u.role_id],
      where: u.user_id == ^user_id,
      where: r.name == ^role_name

    Repo.delete_all(query)
  end

  def delete_user_roles_by_params(params) do
    %UserRoleSearch{}
    |> user_role_changeset(params)
    |> case do
         %Ecto.Changeset{valid?: true, changes: changes} ->
           UserRole |> get_search_query(changes) |> Repo.delete_all()

         changeset
          -> changeset
       end
  end

  defp user_role_changeset(%UserRole{} = user_role, attrs) do
    user_role
    |> cast(attrs, [:user_id, :role_id, :client_id])
    |> validate_required([:user_id, :role_id, :client_id])
    |> unique_constraint(:user_roles, name: :user_roles_user_id_role_id_client_id_index)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:client_id)
  end

  defp user_role_changeset(%UserRoleSearch{} = user_role, attrs) do
    user_role
    |> cast(attrs, [:user_id, :role_id, :client_id])
    |> validate_required([:user_id])
  end
end
