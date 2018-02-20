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

  @edges [
    %{
      from: "com.igwet.contact.Ernest-Prabhakar",
      via: "com.igwet.predicate.in",
      to: "com.igwet.group.Site-Administrators"
    }
  ]

  def reset do
    Repo.delete_all(Node)
    Repo.delete_all(Edge)

    Enum.each @nodes, fn node ->
      Repo.insert! node
    end

    Enum.each @edges, fn edge ->
      %Edge{
        subject: edge.from,
        predicate: edge.via,
        object: edge.to
      }
    end
  end
end

Igwet.Seeds.reset()
