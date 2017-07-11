defmodule Mithril.Utils.String do
  @moduledoc false

  # TODO: split
  def comma_split(str), do: String.split(str, " ", trim: true)
end
