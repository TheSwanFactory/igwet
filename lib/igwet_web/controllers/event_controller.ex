defmodule IgwetWeb.EventController do
  use IgwetWeb, :controller
  require Logger

  alias Igwet.Network
  alias Igwet.Network.Node
  @tz "US/Pacific"
  @default_details %Details{capacity: 100, current: 0, duration: 90, recurrence: 7, timezone: @tz}

  plug(:require_admin)

  def index(conn, _params) do
    event = Network.get_first_node!(:name, "event")
    nodes = Network.related_subjects(event, "type")
    render(conn, "index.html", events: nodes)
  end

 def new(conn, %{"id" => id}) do
   group = Network.get_node!(id)
    {:ok, now} = DateTime.shift_zone(DateTime.utc_now, "US/Pacific")
    key = group.key <> "+" <> DateTime.to_string(now)
    meta = Map.merge(@default_details, %{starting: now, parent_id: group.id})
    defaults = %Node{name: "Our Church Service", about: "In-Person Event Details", meta: meta, key: key}
    changeset = Network.change_node(defaults)
    render(conn, "new.html", changeset: changeset, group: group)
  end

  def create(conn, %{"node" => event_params}) do
    case Network.create_node(event_params) do
      {:ok, event} ->
        #Logger.warn("** created event: " <> inspect(event))
        is_event = Network.get_first_node!(:name, "event")
        Network.make_edge(event, "type", is_event)
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = _changeset} ->
        redirect(conn, to: group_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    event = Network.get_node!(id)
    groups = Network.related_objects(event, "for")
    houses = Network.related_subjects(event, "at")
    render(conn, "show.html", event: event, groups: groups, houses: houses)
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
