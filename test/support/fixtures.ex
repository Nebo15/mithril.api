defmodule Mithril.Fixtures do
  def create_token(details) do
    token_attrs = %{
      user_id: create_user().id,
      details: details
    }

    changeset =
      Authable.Model.Token.access_token_changeset(%Authable.Model.Token{}, token_attrs)

    {:ok, token} =
      Mithril.Repo.insert(changeset)

    token
  end

  def create_client do
    {:ok, client} =
      client_create_attrs()
      |> Mithril.ClientAPI.create_client()

    client
  end

  def create_user do
    {:ok, user} =
      user_create_attrs()
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
      redirect_uri: "localhost",
      client_type_id: create_client_type().id
    }
  end

  def client_type_attrs do
    %{
      name: "some_kind_of_client",
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
end
