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
  # require IEx; #IEx.pry
  alias Igwet.Repo
  alias Igwet.Network
  alias Igwet.Network.Node
  alias Igwet.Network.Edge

  @seed_keys Application.get_env(:igwet, :seed_keys)
  @priv_dir Application.app_dir(:igwet, "priv")
  @seed_csv Path.absname("repo/igwet-seeds.csv", @priv_dir)

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
    create_edge(row, :in)
    create_edge(row, :type)
  end

  def create_edge(row, predicate) do
    object = row[to_string(predicate)]

    if object != "" do
      triple = %{
        from: row["key"],
        by: @seed_keys[predicate],
        to: object
      }

      Repo.insert!(edge_from_triple(triple))
    end
  end

  def csv_create() do
    File.stream!(@seed_csv)
    |> CSV.decode!(headers: true)
    |> Enum.each(&create_node/1)
  end

  def reset do
    Repo.delete_all(Node)
    csv_create()
  end
end

Igwet.Seeds.reset()
