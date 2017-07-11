defmodule Mithril.Authorization.Token do
  @moduledoc false

  # Functions in this module create new access_tokens,
  # based on grant_type the request came with

  alias Mithril.Authorization.GrantType.Password
  alias Mithril.Authorization.GrantType.AuthorizationCode
  alias Mithril.Authorization.GrantType.RefreshToken

  # TODO: rename grant_type to response_type
  def authorize(%{"grant_type" => "password"} = params) do
    Password.authorize(params)
  end

  def authorize(%{"grant_type" => "authorization_code"} = params) do
    AuthorizationCode.authorize(params)
  end

  def authorize(%{"grant_type" => "refresh_token"} = params) do
    RefreshToken.authorize(params)
  end

  def authorize(_) do
    {:error, %{invalid_client: "Request must include grant_type."}, :bad_request}
  end
end
