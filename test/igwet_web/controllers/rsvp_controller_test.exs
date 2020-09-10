require Logger

defmodule IgwetWeb.RsvpControllerTest do
  use IgwetWeb.ConnCase
  doctest IgwetWeb.RsvpController
  alias Igwet.Network
  require Logger

  @group_attrs %{
    about: "about group",
    email: "some.group@email",
    key: "some.group.key",
    name: "group",
    phone: "some group phone"
  }
  @event_attrs %{
    name: "event name",
    about: "about event",
    key: "event.key",
    date: %{year: 2020, month: 4, day: 1, hour: 2, minute: 3},
    timezone: "US/Pacific",
    size: 100,
    meta: %{
      duration: 90,
      parent_id: nil,
      recurrence: 7
    }
  }

  @node_email "test@example.com"

  def attrs(:event) do
    {:ok, group} = Network.create_node(@group_attrs)
    @event_attrs
    |> put_in([:meta, :parent_id], group.id)
  end

  defp create_event(_) do
    {:ok, event} = Network.create_node(attrs(:event))
    %{event: event}
  end

  test "GET /rsvp -> 200", %{conn: conn} do
    conn
    |> get("/rsvp")
    |> response(200)
  end

  describe "attendees" do
    setup [:create_event]

    test "GET /rsvp/for:event -> 200", %{conn: conn, event: event} do
      conn
      |> get("/rsvp/for/" <> event.key)
      |> response(200)
    end

    test "GET /rsvp/for:event/:email -> 200", %{conn: conn, event: event} do
      conn
      |> get("/rsvp/for/" <> event.key <> "/" <> @node_email)
      |> response(200)
    end

    test "POST /rsvp/for:event/:email/:count -> 200", %{conn: conn, event: event} do
      path = ["/rsvp", "for", event.key, @node_email, 3] |> Enum.join("/")
      conn
      |> post(path)
      |> response(302)

      node = Network.get_first_node!(:email, @node_email)
      assert node != nil
      assert Network.member_attendance(node, event) == 3
      assert Network.count_attendance(event) == 3
    end

    test "GET /rsvp/send_email/:event/ -> 200", %{conn: conn, event: event} do
      conn
      |> get("/rsvp/send_email/#{event.key}")
      |> response(302)
    end
  end
end
