defmodule IgwetWeb.EventController do
  use IgwetWeb, :controller

  alias Igwet.Network
  alias Igwet.Network.Event

  def index(conn, _params) do
    events = Network.list_events()
    render(conn, "index.html", events: events)
  end

  def new(conn, _params) do
    changeset = Network.change_event(%Event{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event" => event_params}) do
    case Network.create_event(event_params) do
      {:ok, event} ->
        type = Network.get_first_node!(:name, "event")
        Network.make_edge(node, "type", type)
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    event = Network.get_event!(id)
    render(conn, "show.html", event: event)
  end

  def edit(conn, %{"id" => id}) do
    event = Network.get_event!(id)
    changeset = Network.change_event(event)
    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = Network.get_event!(id)

    case Network.update_event(event, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", event: event, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    event = Network.get_event!(id)
    {:ok, _event} = Network.delete_event(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :index))
  end
end
