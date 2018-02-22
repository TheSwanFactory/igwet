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

  @seed_keys Application.get_env(:igwet, :seed_keys)

  @nodes [
    %Node{name: "type", key: @seed_keys[:type]},
    %Node{name: "in", key: @seed_keys[:in]},
    %Node{
      name: "Site Administrators",
      key: @seed_keys[:admin_group]
    },
    %Node{
      name: "Ernest Prabhakar",
      email: "info@theswanfactory.com",
      key: @seed_keys[:superuser]
    }
  ]

  @triples [
    %{
      from: @seed_keys[:superuser],
      by: @seed_keys[:in],
      to: @seed_keys[:admin_group]
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
