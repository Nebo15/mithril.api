defmodule Mithril.TokenAPI do
  @moduledoc false

  import Ecto.{Query, Changeset}, warn: false
  alias Mithril.Repo

  alias Mithril.TokenAPI.Token

  def list_tokens do
    Repo.all(Token)
  end

  def get_token!(id), do: Repo.get!(Token, id)

  def get_token_by_value!(value), do: Repo.get_by!(Token, value: value)

  def create_token(attrs \\ %{}) do
    %Token{}
    |> token_changeset(attrs)
    |> Repo.insert()
  end

  def create_authorization_code(attrs \\ %{}) do
    %Token{}
    |> authorization_code_changeset(attrs)
    |> Repo.insert()
  end

  def update_token(%Token{} = token, attrs) do
    token
    |> token_changeset(attrs)
    |> Repo.update()
  end

  def delete_token(%Token{} = token) do
    Repo.delete(token)
  end

  def change_token(%Token{} = token) do
    token_changeset(token, %{})
  end

  defp token_changeset(%Token{} = token, attrs) do
    token
    |> cast(attrs, [:name, :user_id, :value, :expires_at, :details])
    |> validate_required([:name, :user_id, :value, :expires_at, :details])
  end

  defp authorization_code_changeset(%Token{} = token, attrs) do
    token
    |> cast(attrs, [:name, :expires_at, :details, :user_id])
    |> validate_required([:user_id])
    |> put_change(:value, SecureRandom.urlsafe_base64)
    |> put_change(:name, "authorization_code")
    |> put_change(:expires_at, :os.system_time(:seconds) + 5 * 60) # valid for 5 minutes
    |> unique_constraint(:value, name: :tokens_value_name_index)
  end
end
