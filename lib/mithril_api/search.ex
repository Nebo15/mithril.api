defmodule Mithril.Search do
  @moduledoc """
  Search implementation
  """

  defmacro __using__(_) do
    quote  do
      import Ecto.{Query, Changeset}, warn: false

      alias Mithril.Paging
      alias Mithril.Repo

      def set_like_attributes(%Ecto.Changeset{valid?: false} = changeset, _like_fields), do: changeset
      def set_like_attributes(%Ecto.Changeset{valid?: true, changes: changes} = changeset, like_fields) do
        Enum.reduce(changes, changeset, fn({key, value}, changeset) ->
          case key in like_fields do
            true -> put_change(changeset, key, {value, :like})
            _ -> changeset
          end
        end)
      end

      def search(%Ecto.Changeset{valid?: true, changes: changes}, search_params, entity, default_limit) do
        entity
        |> get_search_query(changes)
        |> Repo.page(Paging.get_paging(search_params, default_limit))
      end

      def search(%Ecto.Changeset{valid?: false} = changeset, _search_params, _entity, _default_limit) do
        {:error, changeset}
      end

      def get_search_query(entity, changes) when map_size(changes) > 0 do
        params = Enum.filter(changes, fn({key, value}) -> !is_tuple(value) end)

        q = from e in entity,
          where: ^params

        Enum.reduce(changes, q, fn({key, val}, query) ->
          case val do
            {value, :like} -> where(query, [r], ilike(field(r, ^key), ^("%" <> value <> "%")))
            {value, :in} -> where(query, [r], field(r, ^key) in ^value)
            _ -> query
          end
        end)
      end
      def get_search_query(entity, _changes), do: from e in entity

      defoverridable [get_search_query: 2]
    end
  end
end
