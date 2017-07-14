defmodule Mithril.UserAPI do
  @moduledoc """
  The boundary for the UserAPI system.
  """

  import Ecto.{Query, Changeset}, warn: false

  alias Mithril.Paging
  alias Mithril.Repo
  alias Mithril.UserAPI.User

  def list_users(params) do
    User
    |> filter_by_email(params)
    |> Repo.page(Paging.get_paging(params, 50))
  end

  defp filter_by_email(query, %{"email" => email}) when is_binary(email) do
    where(query, [r], r.email == ^email)
  end
  defp filter_by_email(query, _), do: query

  def get_user(id), do: Repo.get(User, id)
  def get_user!(id), do: Repo.get!(User, id)
  def get_user_by(attrs), do: Repo.get_by(User, attrs)

  def get_full_user(user_id, client_id) do
    query = from u in User,
      left_join: ur in assoc(u, :user_roles),
      left_join: r in assoc(ur, :role),
      preload: [roles: r],
      where: ur.user_id == ^user_id,
      where: ur.client_id == ^client_id

    Repo.one(query)
  end

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

  def change_user_password(%User{} = user, user_params) do
    changeset =
      user
      |> user_changeset(user_params)
      |> validate_required([:current_password])
      |> validate_changed(:password)
      |> validate_passwords_match(:password, :current_password)

    if changeset.valid? == true do
      Repo.update(changeset)
    else
      changeset
    end
  end

  defp get_password_hash(password) do
    Comeonin.Bcrypt.hashpwsalt(password)
  end

  defp user_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password, :settings, :current_password])
    |> validate_required([:email, :password])
    |> unique_constraint(:email)
    |> put_password()
  end

  defp put_password(changeset) do
    if password = get_change(changeset, :password) do
      put_change(changeset, :password, get_password_hash(password))
    else
      changeset
    end
  end

  defp validate_changed(changeset, field) do
    case fetch_change(changeset, field) do
      :error -> add_error(changeset, field, "is not changed", validation: :required)
      {:ok, _change} -> changeset
    end
  end

  defp validate_passwords_match(changeset, field1, field2) do
    validate_change changeset, field1, :password, fn _, _new_value ->
      %{data: data} = changeset
      field1_hash = Map.get(data, field1)

      with {:ok, value2} <- fetch_change(changeset, field2),
           true <- Comeonin.Bcrypt.checkpw(value2, field1_hash) do
        []
      else
        :error ->
          []
        false ->
          [{field2,
           {"#{to_string(field1)} does not match password in field #{to_string(field2)}", [validation: :password]}}]
      end
    end
  end
end
