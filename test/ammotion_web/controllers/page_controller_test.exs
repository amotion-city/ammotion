defmodule AmmoWeb.PageControllerTest do
  use AmmoWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Hello Ammo!"
  end
end
