defmodule IgwetWeb.EventController do
  use IgwetWeb, :controller
  require Logger

  alias Igwet.Network
  alias Igwet.Network.Node
  @tz "US/Pacific"

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
    meta = %Details{capacity: 100, duration: 90, recurrence: 7, timezone: @tz, starting: now }
    defaults = %Node{name: "Our Church Service", about: "In-Person Event Details", meta: meta, key: key}
    changeset = Network.change_node(defaults)
    render(conn, "new.html", changeset: changeset, group: group)
  end

  def create(conn, %{"node" => event_params}) do
    Logger.warn("** create event_params: " <> inspect(event_params))
    case Network.create_node(event_params) do
      {:ok, event} ->
        Logger.warn("** create event: " <> inspect(event))
        type = Network.get_first_node!(:name, "event")
        Logger.warn("** create type: " <> inspect(type))
        edge = Network.make_edge(event, "type", type)
        Logger.warn("** create edge: " <> inspect(edge))
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    event = Network.get_node!(id)
    render(conn, "show.html", event: event)
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
