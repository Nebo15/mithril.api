defmodule Mithril.Search do
  @moduledoc """
  Search implementation
  """

  defmacro __using__(_) do
    quote  do
      import Ecto.{Query, Changeset}, warn: false

      alias Mithril.Paging
      alias Mithril.Repo

      def search(%Ecto.Changeset{valid?: true, changes: changes}, search_params, entity, default_limit) do
        entity
        |> get_search_query(changes)
        |> Repo.page(Paging.get_paging(search_params, default_limit))
      end

      def search(%Ecto.Changeset{valid?: false} = changeset, _search_params, _entity, _default_limit) do
        {:error, changeset}
      end

      def get_search_query(entity, changes) when map_size(changes) > 0 do
        params = Map.to_list(changes)

        from e in entity,
          where: ^params
      end
      def get_search_query(entity, _changes), do: from e in entity

      defoverridable [get_search_query: 2]
    end
  end
end
