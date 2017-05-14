defmodule Mithril.Authorization.App do
  @moduledoc """
  App Authorization Policy module
  """

  import Ecto.Query, only: [from: 2]

  # Mithril.Repo Application.get_env(:authable, :repo)
  # Mithril.TokenAPI.Token Application.get_env(:authable, :token_store)
  # @client Application.get_env(:authable, :client)
  # @app Application.get_env(:authable, :app)
  # @scopes Application.get_env(:authable, :scopes)

  # This should be configurable
  @scopes ~w(
    app:authorize
    some_api:read
    some_api:write
    legal_entity:read
    legal_entity:write
    employee_request:write
    employee_request:read
  )

  def grant(%{"user_id" => _, "client_id" => _, "redirect_uri" => _, "scope" => _} = params) do
    params
    |> find_user()
    |> find_client()
    # |> define_scopes_to_be_granted
    |> update_or_create_app()
    |> create_token()
  end

  defp find_client(%{"client_id" => client_id, "redirect_uri" => redirect_uri} = params) do
    case Mithril.ClientAPI.get_client_by([id: client_id, redirect_uri: redirect_uri])
      nil ->
        {:error, %{invalid_client: "Client not found"}, :unprocessable_entity}
      client ->
        Map.put(params, "client", client)
    end
  end

  defp find_user(%{"user_id" => user_id}) do
    case Mithril.Web.UserAPI.get_user(user_id)
      nil ->
        {:error, %{invalid_client: "User not found"}, :unprocessable_entity}
      user ->
        Map.put(params, "user", user)
    end
  end

  defp update_or_create_app({:error, errors, status}) do
    {:error, errors, status}
  end
  defp update_or_create_app(%{"user" => user, "client_id" => client_id, "scope" => scope} = params) do
    app =
      case Mithril.AppAPI.get_app_by!([user_id: user.id, client_id: client_id]) do
        nil -> Mithril.AppAPI.create_app(%{user_id: user.id, client_id: client_id, scope: scope})
        app -> update_app_scopes({app, scope})
      end
    Map.put(params, "app", app)
  end

  defp update_app_scopes({app, scope}) do
    if app.scope != scope do
      scope =
        scope
        |> Authable.Utils.String.comma_split
        |> Enum.concat(Authable.Utils.String.comma_split(app.scope))
        |> Enum.uniq()
      scope = @scopes -- (@scopes -- scope)
      Mithril.Repo.update!(@app.changeset(app, %{scope: Enum.join(scope, ",")}))
    else
      app
    end
  end

  defp create_token({:error, errors, status}) do
    {:error, errors, status}
  end

  defp create_token(%{"user" => user, "client" => client, "app" => app} = params) do
    {:ok, token} = Mithril.TokenAPI.create_authorization_code(%{
      user_id: user.id,
      details: %{
        client_id: client.id,
        redirect_uri: client.redirect_uri,
        scope: app.scope
      }
    })

    Map.put(params, "token", token)
  end
end
