require Logger

defmodule IgwetWeb.RsvpControllerTest do
  use IgwetWeb.ConnCase
  doctest IgwetWeb.RsvpController

  test "GET /rsvp -> 200", %{conn: conn} do
    conn
    |> get("/rsvp")
    |> response(200)
  end

end
