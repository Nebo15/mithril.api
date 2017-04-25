defmodule Trump.Fixtures do
  def user do
  end

  def client_create_attrs do
    %{
      name: "some name",
      priv_settings: %{},
      redirect_uri: "some redirect_uri",
      secret: "some secret",
      settings: %{},
      client_type_id: create_client_type.id
    }
  end

  def create_client_type do
    {:ok, client_type} =
      client_type_attrs
      |> Trump.ClientTypeAPI.create_client_type()

    client_type
  end

  def client_type_attrs do
    %{
      name: "some_kind_of_client",
      scope: "some, scope"
    }
  end
end
