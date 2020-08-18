require Logger
require Protocol
Protocol.derive(Jason.Encoder, RuntimeError)

defmodule IgwetWeb.WebhookControllerTest do
  use IgwetWeb.ConnCase
  use Bamboo.Test
  doctest IgwetWeb.WebhookController

  alias Igwet.Network.SMS
  alias Igwet.Network.Sendmail

  setup %{conn: conn} do
    conn = put_req_header(conn, "content-type", "application/json")
    {:ok, %{conn: conn}}
  end

  test "POST /webhook/twilio -> 201", %{conn: conn} do
    "{\"created_at\":" <> time = conn
    |> post("/webhook/twilio", SMS.test_params("webhook"))
    |> response(201)

    assert nil != time
  end

  test "POST /webhook -> 201", %{conn: conn} do
    conn
    |> post("/webhook", Sendmail.test_params())
    |> response(201)

    assert_email_delivered_with(
      from: {"operator", "com.igwet+admin+operator@example.com"},
      to: [{"operator", "ernest.prabhakar@gmail.com"}]
      # headers: [{"sender", "com.igwet+admin+operator@example.com"}]
    )
  end

  test "POST /webhook -> 422 missing data", %{conn: conn} do
    %{"error" => %{"message" => message}} =
      conn
      |> post("/webhook", %{})
      |> json_response(422)

    assert message =~ "No parameter named"
  end

  test "POST /webhook -> 422 unknown sender", %{conn: conn} do
    params =
      %{sender: "missing-email", recipient: "none", from: "none"}
      |> Map.put("message-headers", [])

    %{"error" => %{"message" => message}} =
      conn
      |> post("/webhook", params)
      |> json_response(422)

    assert message =~ "Unrecognized sender"
  end
end
