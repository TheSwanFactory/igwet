defmodule Igwet.DataImport do
  require Logger
  #import Ecto.{Query}
  #alias Igwet.Network.Edge
  alias Igwet.Network
  #alias Igwet.Repo

  @doc """
  Convert string keys into atoms

  ## Examples
  iex> alias Igwet.DataImport
  iex> DataImport.map_strings_to_atoms %{"KEY" => "value"}
  %{key: "value"}

  """

  def map_strings_to_atoms(string_key_map) do
    # https://stackoverflow.com/questions/31990134/how-to-convert-map-keys-from-strings-to-atoms-in-elixir
    for {key, val} <- string_key_map, into: %{}, do: {String.downcase(key) |> String.to_atom(), val}
  end

  @doc """
  Create a unique key and merge it into the map

  ## Examples
  iex> alias Igwet.DataImport
  iex> alias Igwet.Network
  iex> {:ok, group} = Network.create_node %{name: "group", key: "is.group"}
  iex> DataImport.merge_key(%{}, group).key
  "is.group+001"

  """

  def merge_key(attrs, group) do
    count = length(Network.node_members(group)) + 1
    suffix = count |> Integer.to_string |> String.pad_leading(3, "0")
    attrs
    |> Map.put(:key, "#{group.key}+#{suffix}")
  end

  def link_nodes(_node_map, _group) do
  end



  def csv_map(path) do
    #Logger.warn "csv_map.path: #{path}"
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
