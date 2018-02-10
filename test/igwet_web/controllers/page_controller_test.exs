defmodule IgwetWeb.PageControllerTest do
  use IgwetWeb.ConnCase
  doctest IgwetWeb.PageController

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to IGWET!"
  end
end
