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
  alias Igwet.Network
  alias Igwet.Network.Node
  alias Igwet.Network.Edge

  @seed_keys Application.get_env(:igwet, :seed_keys)
  @priv_dir Application.app_dir(:igwet, "priv")
  @seed_csv Path.absname("repo/igwet-seeds.csv", @priv_dir)

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

  def edge_from_triple(triple) do
    %Edge{
      subject: Network.get_node_by_key!(triple.from),
      predicate: Network.get_node_by_key!(triple.by),
      object: Network.get_node_by_key!(triple.to)
    }
  end

  def create_node(row) do
    changeset = Node.changeset(%Node{}, row)
    Repo.insert!(changeset)
    row
  end

  def create_edge(row, predicate) do
    triple = %{
      from: row[:key],
      by: @seed_keys[predicate],
      to: row[predicate]
    }

    IO.puts("~n create_edge ~n")

    IO.inspect predicate
    IO.inspect triple

    Repo.insert! edge_from_triple(triple)
    row
  end

  def csv_create() do
    File.stream!(@seed_csv)
      |> CSV.decode!(headers: true)
      |> Enum.each(&create_node/1)
      |> Enum.each(&create_edge(&1, :in))
      |> Enum.each(&create_edge(&1, :type))
  end

  def create do
    Enum.each @nodes, fn node ->
      Repo.insert! node
    end

    Enum.each @triples, fn triple ->
      Repo.insert! edge_from_triple(triple)
    end
  end

  def reset do
    Repo.delete_all(Node)

    create()
  end
end

Igwet.Seeds.reset()
