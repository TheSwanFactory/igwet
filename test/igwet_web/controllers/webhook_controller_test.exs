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
    |> post("/webhook", Message.test_params())
    |> response(201)
  end

  test "POST /webhook -> 422 missing data", %{conn: conn} do
    %{"error" => %{"message" => message}} =
      conn
      |> post("/webhook", %{})
      |> json_response(422)

    assert message =~ "No parameter named"
  end

  test "POST /webhook -> 422 unknown sender", %{conn: conn} do
    %{"error" => %{"message" => message}} =
      conn
      |> post("/webhook", %{sender: "missing-email", recipient: "none", from: "none"})
      |> json_response(422)

    assert message =~ "Unrecognized sender"
  end
end
