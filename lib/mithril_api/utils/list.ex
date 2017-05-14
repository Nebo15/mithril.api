defmodule Mithril.Utils.List do
  @moduledoc false

  def subset?(super_list, list) do
    list
    |> Enum.find(fn(item) -> !Enum.member?(super_list, item) end)
    |> is_nil
  end
end
