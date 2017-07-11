defmodule Mithril.Utils.List do
  @moduledoc false

  def subset?(super_list, list) do
    Enum.all?(list, &(&1 in super_list))
  end
end
