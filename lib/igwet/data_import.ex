defmodule Igwet.DataImport do
  require Logger
  #import Ecto.{Query}
  #alias Igwet.Network.Edge
  alias Igwet.Network
  #alias Igwet.Repo

  def map_strings_to_atoms(string_key_map) do
    # https://stackoverflow.com/questions/31990134/how-to-convert-map-keys-from-strings-to-atoms-in-elixir
    for {key, val} <- string_key_map, into: %{}, do: {String.downcase(key) |> String.to_atom(), val}
  end

  def merge_key(attrs, group) do
    node = Network.create_node attrs
    Logger.warn "create_node.node:\n#{inspect(node)}"
    %{index: attrs.index, parent_index: attrs.parent, node_id: node.id}
  end

  def csv_map(path) do
    Logger.warn "csv_map.path: #{path}"
    File.stream!(path)
    |> CSV.decode!(headers: true)
    |> Enum.map(&map_strings_to_atoms/1)
  end

  def create_nodes(map_list, group) do
    for attrs <- map_list do
      attrs
      |> merge_key(group)
      |> Network.create_node
    end
    |> link_nodes(group)
  end

end
