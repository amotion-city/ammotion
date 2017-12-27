defmodule AmmoWeb.Api.V1.AlbumsController.Test do
  use AmmoWeb.ConnCase

  test "GET /api/v1/albums", %{conn: conn} do
    conn = get conn, "/api/v1/albums"
    assert json_response(conn, 200) == %{"albums" => []}
  end

  # test "POST /api/v1/consumers", %{conn: conn} do
  #   assert json_response(consumer!(1.2345, conn), 201) == %{"ok" => "CO-AAAAAAAAA-max"}
  # end

end
