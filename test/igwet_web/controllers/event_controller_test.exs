defmodule IgwetWeb.EventControllerTest do
  use IgwetWeb.ConnCase

  alias Igwet.Network

  @create_attrs %{
    about: "some about",
    email: "some email",
    key: "some key",
    name: "some name",
    phone: "some phone"
  }
  @update_attrs %{
    about: "some updated about",
    email: "some updated email",
    key: "some updated key",
    name: "some updated name",
    phone: "some updated phone"
  }
  @invalid_attrs %{about: nil, email: nil, key: nil, name: nil, phone: nil}

  def fixture(:event) do
    {:ok, event} = Network.create_node(@create_attrs)
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
      conn = get(conn, event_path(conn, :new))
      assert html_response(conn, 200) =~ "New Event"
    end
  end

  describe "create event" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, event_path(conn, :create), event: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == event_path(conn, :show, id)

      conn = get(conn, event_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Event"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, event_path(conn, :create), event: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Event"
    end
  end

  describe "edit event" do
    setup [:create_node]

    test "renders form for editing chosen event", %{conn: conn, event: event} do
      conn = get(conn, event_path(conn, :edit, event))
      assert html_response(conn, 200) =~ "Edit Event"
    end
  end

  describe "update event" do
    setup [:create_node]

    test "redirects when data is valid", %{conn: conn, event: event} do
      conn = put(conn, event_path(conn, :update, event), event: @update_attrs)
      assert redirected_to(conn) == event_path(conn, :show, event)

      conn = get(conn, event_path(conn, :show, event))
      assert html_response(conn, 200) =~ "some updated about"
    end

    test "renders errors when data is invalid", %{conn: conn, event: event} do
      conn = put(conn, event_path(conn, :update, event), event: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Event"
    end
  end

  describe "delete event" do
    setup [:create_node]

    test "deletes chosen event", %{conn: conn, event: event} do
      conn = delete(conn, event_path(conn, :delete, event))
      assert redirected_to(conn) == event_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, event_path(conn, :show, event))
      end
    end
  end

  defp create_node(_) do
    event = fixture(:event)
    %{event: event}
  end
end
