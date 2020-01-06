defmodule MySiteWeb.PageControllerTest do
  use MySiteWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "MKB"
  end
end
