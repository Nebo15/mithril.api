defmodule Trump.Web.PageControllerTest do
  @moduledoc false
  use Trump.Web.ConnCase

  test "GET /page", %{conn: conn} do
    conn = get conn, "/page"

    assert %{
      "meta" => %{
        "url" => _,
        "type" => "object",
        "request_id" => _,
        "code" => 200
      },
      "data" => %{
        "page" => %{
          "detail" => "This is page."
        },
        "type" => "page"
      }
    } = conn |> response(200) |> Poison.decode!
  end
end
