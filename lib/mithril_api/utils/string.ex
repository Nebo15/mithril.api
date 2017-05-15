defmodule Mithril.Utils.String do
  @moduledoc false

  # TODO: just use this directly, no need to have it module
  def comma_split(str), do: String.split(str, " ", trim: true)
end
