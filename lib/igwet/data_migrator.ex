defmodule Igwet.DataMigrator do
  require Logger
  import Ecto.{Query}
  alias Igwet.Network
  alias Igwet.Network.Edge
  alias Igwet.Network.Node
  alias Igwet.Repo

  def run do
    from(
      n in Node,
      preload: [:parent]
    )
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
    if (!is_nil(node.meta) and !is_nil(node.meta.parent_id)) do
      #parent = Network.get_node! node.meta.parent_id
      Network.update_node node, %{parent_id: node.meta.parent_id}
      node2 = Network.get_node!(node.id)
      Logger.warn("inline_parent\n#{inspect(node2)}")
    end
  end

  defp collapse_edge(edge) do
    #Logger.warn("collapse_edge: #{edge.predicate.name}")
    if (edge.predicate.name == "type") do
      inline_type(edge)
      Repo.delete edge
    else
      inline_relation(edge)
    end
  end

  defp inline_type(edge) do
    Network.update_node edge.subject, %{relation: edge.object.name}
    node = Network.get_node!(edge.subject_id)
    if (is_nil node.type) do
      Logger.warn("inline_type:#{edge.object.name}\n #{inspect(node)}")
    end
  end

  defp inline_relation(edge) do
    edge
    |> Edge.changeset(%{relation: edge.predicate.name})
    |> Repo.update()
    if (is_nil edge.subject.type) do
      #Logger.warn("inline_relation: #{edge.predicate.name}\n #{inspect(edge)}")
    end
  end
end
