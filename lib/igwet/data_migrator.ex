defmodule Igwet.DataMigrator do
  import Ecto.{Query, Changeset}
  alias Igwet.Node

  def run do
    Repo.all from n in Node, where !is_nil(n.meta.parent)
    |> Enum.each(&inline_parent/1)

    Repo.all from e in Edge, preload: [:subject, :predicate, :object]
    |> Enum.each(&inline_type/1)
    |> Enum.each(&inline_relation/1)
    :ok
  end

  defp inline_parent(%Node{} node) do
    node.parent_id = node.meta.parent_id
    Network.update_node node
  end

  defp inline_type(%Edge{} edge) do
    node = %Node{id: edge.subject_id, type: edge.object.name}
    Network.update_node node
  end

  defp inline_relation(%Edge{} edge) do
    edge.relation = edge.predicate.name
    Network.update_edge
  end
end
