defmodule IgwetWeb.WebhookControllerTest do
  use IgwetWeb.ConnCase
  doctest IgwetWeb.WebhookController

  alias Igwet.Network.Message

  setup %{conn: conn} do
    conn = put_req_header(conn, "content-type", "application/json")
    {:ok, %{conn: conn}}
  end

  test "POST /webhook -> 201", %{conn: conn} do
    conn
    |> post("/webhook", Message.test_webhook())
    |> response(201)
  end

  test "POST /webhook -> 422", %{conn: conn} do
    conn
    |> post("/webhook", %{})
    |> response(422)
  end
end
