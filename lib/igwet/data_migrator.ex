defmodule Igwet.DataMigrator do
  require Logger
  import Ecto.{Query}
  alias Igwet.Network
  alias Igwet.Network.Edge
  alias Igwet.Repo

  def run do
    from(
      e in Edge,
      preload: [:subject, :predicate, :object]
    )
    |> Repo.all()
    |> Enum.each(&collapse_edge/1)
    :ok
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
    Network.update_node edge.subject, %{type: edge.object.name}
    #node = Network.get_node!(edge.subject_id)
  end

  defp inline_relation(edge) do
    edge
    |> Edge.changeset(%{relation: edge.predicate.name})
    |> Repo.update()
  end
end
