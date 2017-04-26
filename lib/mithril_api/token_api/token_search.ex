defmodule Mithril.TokenApi.TokenSearch do
  def find(%{"id" => _, "client_id" => _, "client_secret" => _} = params) do
    params
    |> find_token()
    |> find_client()
    |> validate_client_token_ownership()
  end

  defp find_token(%{"id" => token_value} = params) do
    case Mithril.Repo.get_by(Authable.Model.Token, value: token_value) do
      nil ->
        {:error, {:not_found, %{id: ["Invalid token identifier!"]}}}
      token ->
        {:ok, Map.put(params, "token", token)}
    end
  end

  defp find_client({:ok, %{"client_id" => id, "client_secret" => secret} = params}) do
    case Mithril.Repo.get_by(Authable.Model.Client, id: id, secret: secret) do
      nil ->
        {:error, {:not_found, %{client_id: ["Invalid client identifier!"]}}}
      client ->
        {:ok, Map.put(params, "client", client)}
    end
  end

  defp find_client({:error, params}),
    do: {:error, params}

  defp validate_client_token_ownership({:ok, %{"token" => token, "client_id" => client_id} = params}) do
    if Map.get(token.details, "client_id", "") == client_id do
      {:ok, params}
    else
      {:error, {:not_found, %{id: ["Invalid client identifier!"]}}}
    end
  end

  defp validate_client_token_ownership({:error, params}),
    do: {:error, params}
end
