defmodule Mithril.TokenAPI do
  @moduledoc false

  import Ecto.{Query, Changeset}, warn: false
  alias Mithril.Repo

  alias Mithril.TokenAPI.Token

  @token_lifetime Application.get_env(:mithril_api, :token_lifetime)
  @access_token_lifetime Keyword.get(@token_lifetime, :access)
  @refresh_token_lifetime Keyword.get(@token_lifetime, :refresh)
  @auth_code_lifetime Keyword.get(@token_lifetime, :code)

  def list_tokens do
    Repo.all(Token)
  end

  def get_token!(id), do: Repo.get!(Token, id)

  def get_token_by_value!(value), do: Repo.get_by!(Token, value: value)
  def get_token_by(attrs), do: Repo.get_by(Token, attrs)

  def create_token(attrs \\ %{}) do
    %Token{}
    |> token_changeset(attrs)
    |> Repo.insert()
  end

  # TODO: create refresh and auth token in transaction
  def create_refresh_token(attrs \\ %{}) do
    %Token{}
    |> refresh_token_changeset(attrs)
    |> Repo.insert()
  end

  def create_authorization_code(attrs \\ %{}) do
    %Token{}
    |> authorization_code_changeset(attrs)
    |> Repo.insert()
  end

  def create_access_token(attrs \\ %{}) do
    %Token{}
    |> access_token_changeset(attrs)
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

  def verify(token_value) do
    token = get_token_by_value!(token_value)

    with false <- expired?(token),
         _app <- Mithril.AppAPI.approval(token.user_id, token.details["client_id"]) do
           # if token is authorization_code or password - make sure was not used previously
        {:ok, token}
    else
      _ ->
        message = "Token expired or client approval was revoked."
        Mithril.Authorization.GrantType.Error.invalid_grant(message)
    end
  end

  def expired?(%Token{} = token) do
    token.expires_at < :os.system_time(:seconds)
  end

  defp token_changeset(%Token{} = token, attrs) do
    token
    |> cast(attrs, [:name, :user_id, :value, :expires_at, :details])
    |> validate_required([:name, :user_id, :value, :expires_at, :details])
  end

  defp refresh_token_changeset(%Token{} = token, attrs) do
    token
    |> cast(attrs, [:name, :expires_at, :details, :user_id])
    |> validate_required([:user_id])
    |> put_change(:value, SecureRandom.urlsafe_base64)
    |> put_change(:name, "refresh_token")
    |> put_change(:expires_at, :os.system_time(:seconds) + @refresh_token_lifetime)
    |> unique_constraint(:value, name: :tokens_value_name_index)
  end

  defp access_token_changeset(%Token{} = token, attrs) do
    token
    |> cast(attrs, [:name, :expires_at, :details, :user_id])
    |> validate_required([:user_id])
    |> put_change(:value, SecureRandom.urlsafe_base64)
    |> put_change(:name, "access_token")
    |> put_change(:expires_at, :os.system_time(:seconds) + @access_token_lifetime)
    |> unique_constraint(:value, name: :tokens_value_name_index)
  end

  defp authorization_code_changeset(%Token{} = token, attrs) do
    token
    |> cast(attrs, [:name, :expires_at, :details, :user_id])
    |> validate_required([:user_id])
    |> put_change(:value, SecureRandom.urlsafe_base64)
    |> put_change(:name, "authorization_code")
    |> put_change(:expires_at, :os.system_time(:seconds) + @auth_code_lifetime)
    |> unique_constraint(:value, name: :tokens_value_name_index)
  end
end
