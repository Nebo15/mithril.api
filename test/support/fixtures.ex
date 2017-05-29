defmodule Mithril.Fixtures do
  def create_client(attrs \\ %{}) do
    {:ok, client} =
      client_create_attrs()
      |> Map.merge(attrs)
      |> Mithril.ClientAPI.create_client()

    client
  end

  def create_user(attrs \\ %{}) do
    {:ok, user} =
      user_create_attrs()
      |> Map.merge(attrs)
      |> Mithril.Web.UserAPI.create_user()

    user
  end

  def create_client_type do
    {:ok, client_type} =
      client_type_attrs()
      |> Mithril.ClientTypeAPI.create_client_type()

    client_type
  end

  def create_role do
    {:ok, role} =
      role_attrs()
      |> Mithril.RoleAPI.create_role()

    role
  end

  def role_attrs do
    %{
      name: "some name",
      scope: "some scope"
    }
  end

  def user_role_attrs do
    %{
      user_id: create_user().id,
      client_id: create_client().id,
      role_id: create_role().id
    }
  end

  def client_create_attrs(name \\ "some name") do
    %{
      name: name,
      redirect_uri: "",
      user_id: create_user().id,
      redirect_uri: "http://localhost",
      client_type_id: create_client_type().id
    }
  end

  def client_type_attrs(name \\ "some_kind_of_client") do
    %{
      name: name,
      scope: "some, scope"
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
end
