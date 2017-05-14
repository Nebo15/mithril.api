defmodule Mithril.Utils.List do
  @moduledoc false

  def subset?(super_list, list) do
    Enum.find(list, fn(item) -> Enum.member?(super_list, item) == false end)
    |> is_nil
  end
end
