defmodule Trump.Web.AuthHooks do
  def after_user_login_success(conn, data) do
    require IEx
    IEx.pry()
    IO.inspect data, label: "======"

    conn
  end

  use Shield.Hook
end
