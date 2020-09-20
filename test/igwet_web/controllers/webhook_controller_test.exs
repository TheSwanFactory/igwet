require Logger

defmodule IgwetWeb.WebhookControllerTest do
  use IgwetWeb.ConnCase
  use Bamboo.Test
  doctest IgwetWeb.WebhookController

  alias Igwet.Network
  alias Igwet.Network.SMS
  alias Igwet.Network.Sendmail

  setup %{conn: conn} do
    conn = put_req_header(conn, "content-type", "application/json")
    {:ok, %{conn: conn}}
  end

  test "POST /webhook/log_sms -> 201", %{conn: conn} do
    params = SMS.test_params("log_sms")
    node = Network.get_first_node!(:phone, params["From"])
    assert !is_nil node
    assert 0 == length(Network.related_subjects(node, "from"))

    "{\"created_at\":" <> time = conn
    |> post("/webhook/log_sms", params)
    |> response(201)

    assert !is_nil time
    results = Network.related_subjects(node, "from")
    assert 1 == length(results)
    result = Enum.at(results,0)
    assert "Hello, Twirled!" == result.name
    assert 15 == result.size
    assert !is_nil result.date
    assert result.about =~ "Twirled"
    #Logger.warn("result\n" <> inspect(result))
  end

  test "POST /webhook/twilio -> 201", %{conn: conn} do
    "{\"created_at\":" <> time = conn
    |> post("/webhook/twilio", SMS.test_params("webhook"))
    |> response(201)

    assert !is_nil time
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
