defmodule IgwetWeb.EventController do
  use IgwetWeb, :controller
  require Logger

  alias Igwet.Network
  alias Igwet.Network.Node
  @tz "US/Pacific"
  @default_details %Details{duration: 90, recurrence: 7}
  @default_event %Node{name: "Our Church Service", about: "In-Person Event Details", size: 100, timezone: @tz}

  plug(:require_admin)

  def index(conn, _params) do
    nodes = Network.get_nodes_of_type("event")
    render(conn, "index.html", events: nodes)
  end

  def new(conn, %{"id" => id}) do
    group = Network.get_node!(id)
    {:ok, now} = DateTime.shift_zone(DateTime.utc_now, "US/Pacific")
    key = group.key <> "+" <> DateTime.to_string(now)
    meta = Map.merge(@default_details, %{parent_id: group.id})
    defaults = Map.merge(@default_event, %{date: now, meta: meta, key: key})
    changeset = Network.change_node(defaults)
    render(conn, "new.html", changeset: changeset, group: group)
  end

  def create(conn, %{"node" => event_params}) do
    case Network.create_event(event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:error, "Event creation failed.\n#{inspect(event_params)}")
        |> redirect(to: group_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    event = Network.get_node!(id)
    attendees = Network.related_subjects(event, "at")
    group = if (event.meta && event.meta.parent_id) do
       Network.get_node!(event.meta.parent_id)
    end
    emails = if (group) do
      (Network.node_members(group) -- attendees)
      |> Enum.map(fn m -> "#{m.name} <#{m.email}>" end)
      |> Enum.join(", ")
    end
    #url = @server <> rsvp_path(conn, :by_event, event.key)
    conn
    |> assign(:group, group)
    |> assign(:reminders, emails)
    |> assign(:attendees, attendees)
    |> render("show.html", event: event)
  end

  def edit(conn, %{"id" => id}) do
    event = Network.get_node!(id)
    changeset = Network.change_node(event)
    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def update(conn, %{"id" => id, "node" => event_params}) do
    event = Network.get_node!(id)

    case Network.update_node(event, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", event: event, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    event = Network.get_node!(id)
    {:ok, _event} = Network.delete_node(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: event_path(conn, :index))
  end
end
