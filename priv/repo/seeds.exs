# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Igwet.Repo.insert!(%Igwet.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

defmodule Igwet.Seeds do
  import Ecto.Query

  alias Igwet.Repo
  alias Igwet.Network.Node
  alias Igwet.Network.Edge

  @nodes [
    %Node{name: "in", key: "com.igwet.predicate.in"},
    %Node{
      name: "Site Administrators",
      key: "com.igwet.group.Site-Administrators"
    },
    %Node{
      name: "Ernest Prabhakar",
      email: "info@theswanfactory.com",
      key: "com.igwet.contact.Ernest-Prabhakar"
    }
  ]

  @triples [
    %{
      from: "com.igwet.contact.Ernest-Prabhakar",
      by: "com.igwet.predicate.in",
      to: "com.igwet.group.Site-Administrators"
    }
  ]

  def node_for_key(key) do
    Node |> where([n], n.key == ^key) |> Repo.one!()
  end

  def edge_from_triple(triple) do
    %Edge{
      subject: node_for_key(triple.from),
      predicate: node_for_key(triple.by),
      object: node_for_key(triple.to)
    }
  end

  def reset do
    Repo.delete_all(Node)

    Enum.each @nodes, fn node ->
      Repo.insert! node
    end

    Enum.each @triples, fn triple ->
      Repo.insert! edge_from_triple(triple)
    end
  end
end

Igwet.Seeds.reset()
