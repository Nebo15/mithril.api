defmodule Mithril.Web.UserAPI do
  @moduledoc """
  The boundary for the UserAPI system.
  """

  import Ecto.{Query, Changeset}, warn: false
  import Mithril.Paging

  alias Mithril.Repo
  alias Mithril.Web.UserAPI.User

  def list_users(params) do
    User
    |> filter_by_email(params)
    |> Repo.page(get_paging(params, 50))
  end

  defp filter_by_email(query, %{"email" => email}) when is_binary(email) do
    where(query, [r], r.email == ^email)
  end
  defp filter_by_email(query, _), do: query

  def get_user(id), do: Repo.get(User, id)
  def get_user!(id), do: Repo.get!(User, id)

  def create_user(attrs \\ %{}) do
    %User{}
    |> user_changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> user_changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    user_changeset(user, %{})
  end

  defp user_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password, :settings])
    |> validate_required([:email, :password])
    |> put_password()
  end

  defp put_password(changeset) do
    if password = get_change(changeset, :password) do
      secured_password = Comeonin.Bcrypt.hashpwsalt(password)

      put_change(changeset, :password, secured_password)
    else
      changeset
    end
  end
end
