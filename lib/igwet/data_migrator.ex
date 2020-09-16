defmodule Igwet.DataMigrator do
  import Ecto.{Query} #Changeset
  alias Igwet.Network
  alias Igwet.Network.Edge
  alias Igwet.Network.Node
  alias Igwet.Repo

  def run do
    from(n in Node, where: not is_nil(n.meta))
    |> Repo.all()
    |> Enum.each(&inline_parent/1)

    from(
      e in Edge,
      preload: [:subject, :predicate, :object]
    )
    |> Repo.all()
    |> Enum.each(&collapse_edge/1)
    :ok
  end

  defp inline_parent(node) do
    if (node.meta.parent_id) do
      parent = Network.get_node! node.meta.parent_id
      Network.update_node node, %{parent: parent}
    end
  end

  defp collapse_edge(edge) do
    if (edge.predicate.name == "type") do
      inline_type(edge)
      Repo.delete edge
    else
      inline_relation(edge)
    end
  end

  defp inline_type(edge) do
    Network.update_node edge.subject, %{relation: edge.object.name}
  end

  defp inline_relation(edge) do
    edge
    |> Edge.changeset(%{relation: edge.predicate.name})
    |> Repo.update()
  end
end
