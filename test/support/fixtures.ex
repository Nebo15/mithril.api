defmodule Mithril.Fixtures do
  def create_client(attrs \\ %{}) do
    {:ok, client} =
      "some #{inspect :rand.normal()} client"
      |> client_create_attrs(Map.get(attrs, :client_type_id))
      |> Map.merge(attrs)
      |> Mithril.ClientAPI.create_client()

    client
  end

  def create_user(attrs \\ %{}) do
    {:ok, user} =
      user_create_attrs()
      |> Map.merge(attrs)
      |> Mithril.UserAPI.create_user()

    user
  end

  def create_client_type(attrs \\ %{}) do
    {:ok, client_type} =
      client_type_attrs()
      |> Map.merge(attrs)
      |> Mithril.ClientTypeAPI.create_client_type()

    client_type
  end

  def create_role(attrs \\ %{}) do
    {:ok, role} =
      role_attrs()
      |> Map.merge(attrs)
      |> Mithril.RoleAPI.create_role()

    role
  end

  def role_attrs do
    %{
      name: "some name",
      scope: "some scope"
    }
  end

  def user_role_attrs(user_id \\ create_user().id) do
    %{
      user_id: user_id,
      client_id: create_client().id,
      role_id: create_role().id
    }
  end

  def client_create_attrs(name \\ "some name", client_type_id \\ nil) do
    client_type_id = if client_type_id, do: client_type_id, else: create_client_type().id

    %{
      name: name,
      user_id: create_user().id,
      redirect_uri: "http://localhost",
      client_type_id: client_type_id
    }
  end

  def client_type_attrs(name \\ "some_kind_of_client") do
    %{
      name: name,
      scope: "some scope"
    }
  end

  def user_create_attrs do
    %{
      email: "some #{inspect :rand.normal()} email",
      password: "some password",
      settings: %{}
    }
  end

  def create_code_grant_token(client, user, expires_at \\ 2000000000) do
    Mithril.TokenAPI.create_token(%{
      details: %{
        scope: "app:authorize",
        client_id: client.id,
        grant_type: "password",
        redirect_uri: client.redirect_uri
      },
      user_id: user.id,
      expires_at: expires_at,
      name: "authorization_code",
      value: "some_short_lived_code"
    })
  end

  def create_refresh_token(client, user, expires_at \\ 2000000000) do
    Mithril.TokenAPI.create_token(%{
      details: %{
        scope: "legal_entity:read legal_entity:write",
        client_id: client.id,
        grant_type: "authorization_code",
      },
      user_id: user.id,
      expires_at: expires_at,
      name: "refresh_token",
      value: "some_refresh_token_code"
    })
  end

  def create_access_token(client, user, expires_at \\ 2000000000) do
    Mithril.TokenAPI.create_token(%{
      details: %{
        scope: "legal_entity:read legal_entity:write",
        client_id: client.id,
        grant_type: "refresh_token",
      },
      user_id: user.id,
      expires_at: expires_at,
      name: "access_token",
      value: "some_access_token"
    })
  end
end
