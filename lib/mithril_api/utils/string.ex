defmodule Mithril.Utils.String do
  @moduledoc false

  def comma_split(str), do: String.split(str, " ", trim: true)
end
