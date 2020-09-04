defmodule IgwetWeb.EventControllerTest do
  use IgwetWeb.ConnCase
  alias Igwet.Network
  require Logger

  @group_attrs %{
    about: "about group",
    email: "some group email",
    key: "some event group key",
    name: "group",
    phone: "some group phone"
  }
  @create_attrs %{
    name: "event name",
    key: "event key",
    date: %{year: 2020, month: 4, day: 1, hour: 2, minute: 3},
    timezone: "US/Pacific",
    size: 100,
    meta: %{
      duration: 90,
      parent_id: nil,
      recurrence: 7
    }
  }
  @update_attrs %{
    name: "some updated event",
    key: "some updated event key",
    date: %{year: 2000, month: 12, day: 31, hour: 23, minute: 59},
    timezone: "US/Eastern",
    size: 60,
    meta: %{
      duration: 120,
      parent_id: nil,
      recurrence: 30
    }
  }
  @invalid_attrs %{about: nil, email: nil, key: nil, name: nil, phone: nil, meta: %{}}

  def attrs(:event) do
    {:ok, group} = Network.create_node(@group_attrs)
    @create_attrs
    |> put_in([:meta, :parent_id], group.id)
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
      conn = post(conn, event_path(conn, :create), node: attrs(:event))

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == event_path(conn, :show, id)

      conn = get(conn, event_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Event"
    end

    test "for group", %{conn: conn} do
      my_attrs = attrs(:event)
      post(conn, event_path(conn, :create), node: my_attrs)

      my_event = Network.get_predicate(my_attrs.name)
      assert Network.get_type(my_event) == "event"

      edges = Igwet.Repo.all(Ecto.assoc(my_event, :edges))
      assert Enum.count(edges) == 2
      edge = Enum.at(edges, 1)
      assert edge.object_id == my_event.meta.parent_id
    end

    test "redirects when data is invalid", %{conn: conn} do
      conn = post(conn, event_path(conn, :create), node: @invalid_attrs)
      assert html_response(conn, 302) =~ "redirected"
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
      assert html_response(conn, 200) =~ "some updated event"
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
    {:ok, event} = Network.create_node(attrs(:event))
    %{event: event}
  end
end
