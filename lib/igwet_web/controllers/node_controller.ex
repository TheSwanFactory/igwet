defmodule IgwetWeb.NodeController do
  use IgwetWeb, :controller

  alias Igwet.Network
  alias Igwet.Network.Node

  plug :require_admin

  def index(conn, _params) do
    nodes = Network.list_nodes()
    render(conn, "index.html", nodes: nodes)
  end

  def new(conn, _params) do
    changeset = Network.change_node(%Node{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"node" => node_params}) do
    case Network.create_node(node_params) do
      {:ok, node} ->
        conn
        |> put_flash(:info, "Node created successfully.")
        |> redirect(to: node_path(conn, :show, node))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    node = Network.get_node!(id)
    groups = []
    members = []
    render(conn, "show.html", node: node, groups: groups, members: members)
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
        conn
        |> put_flash(:info, "Node updated successfully.")
        |> redirect(to: node_path(conn, :show, node))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", node: node, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    node = Network.get_node!(id)
    {:ok, _node} = Network.delete_node(node)

    conn
    |> put_flash(:info, "Node deleted successfully.")
    |> redirect(to: node_path(conn, :index))
  end
end
