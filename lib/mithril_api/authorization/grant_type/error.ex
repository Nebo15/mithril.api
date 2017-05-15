defmodule Mithril.Authorization.GrantType.Error do
  @moduledoc false

  @doc false
  def access_denied(msg),
    do: {:error, %{access_denied: msg}, :unauthorized}

  @doc false
  def invalid_request(msg),
    do: {:error, %{invalid_request: msg}, :bad_request}

  @doc false
  def invalid_client(msg),
    do: {:error, %{invalid_client: msg}, :unauthorized}

  @doc false
  def invalid_grant(msg),
    do: {:error, %{invalid_grant: msg}, :unauthorized}

  @doc false
  def invalid_scope(scopes) do
    {:error, %{invalid_scope:
      "Allowed scopes for the token are #{Enum.join(scopes, ", ")}."},
      :bad_request}
  end

  @doc false
  def unauthorized_client(msg),
    do: {:error, %{unauthorized_client: msg}, :unauthorized}

  @doc false
  def unsupported_grant_type do
    {:error, %{unsupported_grant_type: "The authorization grant type is not
      supported by the authorization server."}, :bad_request}
  end
end
