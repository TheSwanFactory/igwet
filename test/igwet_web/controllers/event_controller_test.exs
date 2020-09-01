defmodule IgwetWeb.EventControllerTest do
  use IgwetWeb.ConnCase

  alias Igwet.Network

  @group_attrs %{
    about: "some about",
    email: "some email",
    key: "some key",
    name: "some name",
    phone: "some phone"
  }
  @create_attrs %{
    name: "event name",
    key: "event key",
    meta: %{
      capacity: 100,
      duration: 90,
      recurrence: 7,
      starting: %{year: 2020, month: 4, day: 1, hour: 2, minute: 3},
      timezone: "US/Pacific"
    }
  }
  @update_attrs %{
    name: "some updated name",
    key: "some updated key",
    meta: %{
      capacity: 60,
      duration: 120,
      recurrence: 30,
      starting: %{year: 2000, month: 12, day: 31, hour: 23, minute: 59},
      timezone: "US/Eastern"
    }
  }
  @invalid_attrs %{about: nil, email: nil, key: nil, name: nil, phone: nil}

  def fixture(:event) do
    {:ok, group} = Network.create_node(@group_attrs)
    {:ok, event} = Network.create_node(@create_attrs)
    Network.get_predicate("for")
    Network.make_edge(event, "for", group)
    event
  end

  describe "index" do
    test "lists all events", %{conn: conn} do
      conn = get(conn, event_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Events"
    end
  end

  describe "new event" do
    test "renders form", %{conn: conn} do
      {:ok, group} = Network.create_node(@group_attrs)
      conn = get(conn, event_path(conn, :new, id: group.id))
      assert html_response(conn, 200) =~ "New Event"
    end
  end

  describe "create event" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, event_path(conn, :create), node: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == event_path(conn, :show, id)

      conn = get(conn, event_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Event"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, event_path(conn, :create), node: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Event"
    end
  end

  describe "edit event" do
    setup [:create_event]

    test "renders form for editing chosen event", %{conn: conn, event: event} do
      conn = get(conn, event_path(conn, :edit, event))
      assert html_response(conn, 200) =~ "Edit Event"
    end
  end

  describe "update event" do
    setup [:create_event]

    test "redirects when data is valid", %{conn: conn, event: event} do
      conn = put(conn, event_path(conn, :update, event), node: @update_attrs)
      assert redirected_to(conn) == event_path(conn, :show, event)

      conn = get(conn, event_path(conn, :show, event))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, event: event} do
      conn = put(conn, event_path(conn, :update, event), node: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Event"
    end
  end

  describe "delete event" do
    setup [:create_event]

    test "deletes chosen event", %{conn: conn, event: event} do
      conn = delete(conn, event_path(conn, :delete, event))
      assert redirected_to(conn) == event_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, event_path(conn, :show, event))
      end
    end
  end

  defp create_event(_) do
    event = fixture(:event)
    %{event: event}
  end
end
