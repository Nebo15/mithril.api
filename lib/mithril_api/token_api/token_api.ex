defmodule Mithril.TokenAPI do
  @moduledoc false

  use Mithril.Search
  import Ecto.{Query, Changeset}, warn: false

  alias Mithril.Paging
  alias Mithril.Repo
  alias Mithril.TokenAPI.Token
  alias Mithril.TokenAPI.TokenSearch

  def list_tokens(params) do
    %TokenSearch{}
    |> token_changeset(params)
    |> search(params, Token, 50)
  end

  def get_search_query(entity, %{client_id: client_id} = changes) do
    params =
      changes
      |> Map.delete(:client_id)
      |> Map.to_list()

    details_params = %{client_id: client_id}
    from e in entity,
      where: ^params,
      where: fragment("? @> ?", e.details, ^details_params)
  end
  def get_search_query(entity, changes), do: super(entity, changes)

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

  def delete_tokens_by_user(user_id) do
    query = from(t in Token, where: t.user_id == ^user_id)
    Repo.delete_all(query)
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

  @uuid_regex ~r|[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}|

  defp token_changeset(%Token{} = token, attrs) do
    token
    |> cast(attrs, [:name, :user_id, :value, :expires_at, :details])
    |> validate_format(:user_id, @uuid_regex)
    |> validate_required([:name, :user_id, :value, :expires_at, :details])
  end

  defp token_changeset(%TokenSearch{} = token, attrs) do
    token
    |> cast(attrs, [:name, :value, :user_id, :client_id])
    |> validate_format(:user_id, @uuid_regex)
    |> set_like_attributes([:name, :value])
  end

  defp refresh_token_changeset(%Token{} = token, attrs) do
    token
    |> cast(attrs, [:name, :expires_at, :details, :user_id])
    |> validate_required([:user_id])
    |> put_change(:value, SecureRandom.urlsafe_base64)
    |> put_change(:name, "refresh_token")
    |> put_change(:expires_at, :os.system_time(:seconds) + Map.fetch!(get_token_lifetime(), :refresh))
    |> unique_constraint(:value, name: :tokens_value_name_index)
  end

  defp access_token_changeset(%Token{} = token, attrs) do
    token
    |> cast(attrs, [:name, :expires_at, :details, :user_id])
    |> validate_required([:user_id])
    |> put_change(:value, SecureRandom.urlsafe_base64)
    |> put_change(:name, "access_token")
    |> put_change(:expires_at, :os.system_time(:seconds) + Map.fetch!(get_token_lifetime(), :access))
    |> unique_constraint(:value, name: :tokens_value_name_index)
  end

  defp authorization_code_changeset(%Token{} = token, attrs) do
    token
    |> cast(attrs, [:name, :expires_at, :details, :user_id])
    |> validate_required([:user_id])
    |> put_change(:value, SecureRandom.urlsafe_base64)
    |> put_change(:name, "authorization_code")
    |> put_change(:expires_at, :os.system_time(:seconds) + Map.fetch!(get_token_lifetime(), :code))
    |> unique_constraint(:value, name: :tokens_value_name_index)
  end

  defp get_token_lifetime,
    do: Confex.fetch_env!(:mithril_api, :token_lifetime)
end
