defmodule IgwetWeb.ReminderController do
  use IgwetWeb, :controller
  require Logger

  alias Igwet.Network
  alias Igwet.Network.Node
  alias Igwet.Scheduler

  plug(:require_admin)

  def index(conn, _params) do
    nodes = Network.get_nodes_of_type("reminder")
    render(conn, "index.html", nodes: nodes)
  end

  def new(conn, _params) do
    {:ok, now} = DateTime.shift_zone(DateTime.utc_now, "US/Pacific")
    changeset = Network.change_node(%Node{date: now, type: "reminder"})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"node" => node_params}) do
    case Network.create_node(node_params) do
      {:ok, node} ->
        Scheduler.node_set_status(node, true)
        conn
        |> put_flash(:info, "Reminder scheduled.")
        |> redirect(to: reminder_path(conn, :show, node))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    node = Network.get_node!(id)
    groups = Network.node_groups(node)
    members = Network.node_members(node)
    messages = Network.related_subjects(node, "from")

    render(conn, "show.html", node: node, groups: groups, members: members, messages: messages)
  end

  def edit(conn, %{"id" => id}) do
    node = Network.get_node!(id)
    changeset = Network.change_node(node)
    render(conn, "edit.html", node: node, changeset: changeset)
  end

  def update(conn, %{"id" => id, "node" => node_params}) do
    node = Network.get_node!(id)

    case Network.update_node(node, node_params) do
      {:ok, node} ->
        active = if (node.meta && !node.meta.hidden), do: true, else: false
        Scheduler.node_set_status(node, active)
        conn
        |> put_flash(:info, "Reminder updated to active=#{active}")
        |> redirect(to: reminder_path(conn, :show, node))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", node: node, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    node = Network.get_node!(id)
    {:ok, _node} = Network.delete_node(node)

    conn
    |> put_flash(:info, "Reminder deleted successfully.")
    |> redirect(to: reminder_path(conn, :index))
  end
end
