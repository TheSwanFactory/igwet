defmodule Igwet.DataMigrator do
  import Ecto.{Query} #Changeset
  alias Igwet.Network
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
    _parent_id = node.meta.parent_id
    #node.parent_id = parent_id
    Network.update_node node
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
    node = %Node{id: edge.subject_id, type: edge.object.name}
    Network.update_node node
  end

  defp inline_relation(edge) do
    #edge.relation = edge.predicate.name
    Network.update_edge edge
  end
end
