defmodule IgwetWeb.AuthControllerTest do
  use IgwetWeb.ConnCase
  doctest IgwetWeb.AuthController

  test "redirects user to Auth0 for authentication", %{conn: conn} do
    conn = get(conn, "/auth/auth0")
    assert redirected_to(conn, 302)
  end
end
