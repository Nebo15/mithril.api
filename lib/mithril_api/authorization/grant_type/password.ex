defmodule Mithril.Authorization.GrantType.Password do
  @moduledoc false

  @scopes ~w(
    app:authorize
    some_api:read
    some_api:write
    legal_entity:read
    legal_entity:write
    employee_request:write
    employee_request:read
  )

  alias Mithril.Authorization.GrantType.Error, as: GrantTypeError

  def authorize(%{"email" => email, "password" => password, "client_id" => client_id, "scope" => scopes}) do
    client = Mithril.ClientAPI.get_client(client_id)
    user = Mithril.Web.UserAPI.get_user_by([email: email])
    create_token(client, user, password, scopes)
  end
  def authorize(_) do
    GrantTypeError.invalid_request("Request must include at least email, password, client_id and scope parameters.")
  end

  defp create_token(nil, _, _, _),
    do: GrantTypeError.invalid_client("Invalid client id.")
  defp create_token(_, nil, _, _),
    do: GrantTypeError.invalid_grant("Identity not found.")
  defp create_token(client, user, password, scopes) do
    {:ok, user}
    |> match_with_user_password(password)
    |> validate_token_scope(scopes)
    |> create_access_token(client, scopes)
  end

  defp create_access_token({:error, err, code}, _, _), do: {:error, err, code}
  defp create_access_token({:ok, user}, client, scope) do
    Mithril.TokenAPI.create_access_token(%{
      user_id: user.id,
      details: %{
        grant_type: "password",
        client_id: client.id,
        scope: scope,
        redirect_uri: client.redirect_uri
      }
    })
  end

  defp validate_token_scope({:error, err, code}, _), do: {:error, err, code}
  defp validate_token_scope({:ok, user}, required_scopes) do
    scopes = @scopes
    required_scopes = Mithril.Utils.String.comma_split(required_scopes)
    if Mithril.Utils.List.subset?(scopes, required_scopes) do
      {:ok, user}
    else
      GrantTypeError.invalid_scope(scopes)
    end
  end

  defp match_with_user_password({:ok, user}, password) do
    if Comeonin.Bcrypt.checkpw(password, Map.get(user, :password, "")) do
      {:ok, user}
    else
      GrantTypeError.invalid_grant("Identity, password combination is wrong.")
    end
  end
end
