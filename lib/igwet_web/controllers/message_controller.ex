defmodule IgwetWeb.MessageController do
  use IgwetWeb, :controller

  alias Igwet.Network

  plug(:require_admin)

  def index(conn, _params) do
    nodes = Network.subjects_for_predicate("from")
    render(conn, "index.html", nodes: nodes)
  end

  def show(conn, %{"id" => id}) do
    node = Network.get_node!(id)
    render(conn, "show.html", node: node)
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
        |> redirect(to: message_path(conn, :show, node))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", node: node, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    node = Network.get_node!(id)
    {:ok, _node} = Network.delete_node(node)

    conn
    |> put_flash(:info, "Node deleted successfully.")
    |> redirect(to: message_path(conn, :index))
  end
end
