defmodule Trump.Web.PageController do
  @moduledoc """
  Sample controller for generated application.
  """
  use Trump.Web, :controller

  action_fallback Trump.Web.FallbackController

  def index(conn, _params) do
    render conn, "page.json"
  end
end
