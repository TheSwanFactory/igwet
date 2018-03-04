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
  alias Igwet.Network.Node
  alias Igwet.Network.Factory

  @priv_dir Application.app_dir(:igwet, "priv")
  @seed_csv Path.absname("repo/igwet-seeds.csv", @priv_dir)

  def map_strings_to_atoms(string_key_map) do
    # https://stackoverflow.com/questions/31990134/how-to-convert-map-keys-from-strings-to-atoms-in-elixir
    map = for {key, val} <- string_key_map, into: %{}, do: {String.to_atom(key), val}
    filtered = :maps.filter(fn _, v -> v != "" end, map)
    Factory.create_child_node!(filtered)
  end

  def csv_create() do
    File.stream!(@seed_csv)
    |> CSV.decode!(headers: true)
    |> Enum.each(&map_strings_to_atoms/1)
  end

  def reset do
    Repo.delete_all(Node)
    csv_create()
  end
end

Igwet.Seeds.reset()
