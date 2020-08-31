defmodule IgwetWeb.EventController do
  use IgwetWeb, :controller

  alias Igwet.Network
  alias Igwet.Network.Node

  plug(:require_admin)

  def index(conn, _params) do
    event = Network.get_first_node!(:name, "event")
    nodes = Network.related_subjects(event, "type")
    render(conn, "index.html", events: nodes)
  end

#  def new(conn, %{"id" => _id}) do

  def new(conn, _params) do
    changeset = Network.change_node(%Node{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event" => event_params}) do
    case Network.create_node(event_params) do
      {:ok, event} ->
        type = Network.get_first_node!(:name, "event")
        Network.make_edge(event, "type", type)
        Network.update_instance(event, event_params)
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

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = Network.get_node!(id)

    case Network.update_node(event, event_params) do
      {:ok, event} ->
        Network.update_instance(event, event_params)
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
