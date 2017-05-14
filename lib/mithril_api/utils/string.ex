defmodule Mithril.Utils.String do
  @moduledoc false

  def comma_split(str), do: trim_split(str, ",")

  defp trim_split(str, char) do
    str
    |> String.replace(~r/([\s]+)/, "")
    |> String.split(char, trim: true)
  end
end
