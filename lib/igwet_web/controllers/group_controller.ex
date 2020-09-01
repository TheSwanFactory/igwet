defmodule IgwetWeb.GroupController do
  use IgwetWeb, :controller

  alias Igwet.Network
  alias Igwet.Network.Node

  plug(:require_admin)

  def index(conn, _params) do
    group = Network.get_first_node!(:name, "group")
    nodes = Network.related_subjects(group, "type")
    render(conn, "index.html", nodes: nodes)
  end

  def new(conn, _params) do
    changeset = Network.change_node(%Node{})
    render(conn, "new.html", changeset: changeset, all_members: nil)
  end

  def create(conn, %{"node" => node_params}) do
    case Network.create_node(node_params) do
      {:ok, node} ->
        group = Network.get_first_node!(:name, "group")
        Network.make_edge(node, "type", group)
        conn
        |> put_flash(:info, "Node created successfully.")
        |> redirect(to: group_path(conn, :show, node))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    node = Network.get_node!(id)
    groups = Network.node_groups(node)
    members = Network.node_members(node)
    events = Network.related_subjects(node, "for")
    render(conn, "show.html", node: node, groups: groups, members: members, events: events)
  end

  def edit(conn, %{"id" => id}) do
    node = Network.get_node!(id)
    changeset = Network.change_node(node)
    my_members = Network.node_members(node)
    all_members = Network.get_nodes_unlike_key(".%")
    render(conn, "edit.html", node: node, changeset: changeset, my_members: my_members, all_members: all_members)
  end

  def update(conn, %{"id" => id, "node" => node_params}) do
    node = Network.get_node!(id)

    case Network.update_node(node, node_params) do
      {:ok, node} ->
        members = Network.node_members(node)
        Network.update_members(node, members, node_params)
        conn
        |> put_flash(:info, "Node updated successfully.")
        |> redirect(to: group_path(conn, :show, node))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", node: node, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    node = Network.get_node!(id)
    {:ok, _node} = Network.delete_node(node)

    conn
    |> put_flash(:info, "Node deleted successfully.")
    |> redirect(to: group_path(conn, :index))
  end
end
