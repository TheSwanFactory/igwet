defmodule Igwet.DataImport do
  require Logger
  #alias Igwet.Network.Node
  alias Igwet.Network

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
  Read a file and convert it into a list of atom-maps
  """

  def csv_map(path) do
    #Logger.warn "csv_map.path: #{path}"
    File.stream!(path)
    |> CSV.decode!(headers: true)
    |> Enum.map(&map_strings_to_atoms/1)
  end

  @doc """
  Create a unique key and merge it into the map

  ## Examples
  iex> alias Igwet.DataImport
  iex> alias Igwet.Network
  iex> {:ok, group} = Network.create_node %{name: "group", key: "is.group"}
  iex> merged = DataImport.merge_key(%{}, group)
  iex> merged.key
  "is.group+001"
  iex> merged.meta
  %{parent_id: group.id}

  """

  def merge_key(attrs, group) do
    count = length(Network.node_members(group)) + 1
    suffix = count |> Integer.to_string |> String.pad_leading(3, "0")
    attrs
    |> Map.put(:key, "#{group.key}+#{suffix}")
    |> Map.put(:meta, %{parent_id: group.id})
  end

  @doc """
  Create nodes using key from group

  ## Examples
  iex> alias Igwet.DataImport
  iex> alias Igwet.Network
  iex> {:ok, group} = Network.create_node %{name: "group", key: "is.group"}
  iex> attrs = %{name: "n", index: 2, parent: 1}
  iex> node_maps = DataImport.upsert_nodes([attrs], group)
  iex> length(node_maps)
  1
  iex> map = Enum.at(node_maps, 0)
  iex> is_nil map.node
  false
  iex> map.node_index
  2
  iex> map.parent_index
  1

  """

  def upsert_nodes(map_list, group) do
    for attrs <- map_list do
      {:ok, node} = attrs |> merge_key(group) |> upsert_on_email()
      %{node: node, node_index: attrs.index, parent_index: attrs.parent}
    end
  end

  def node_if_email(attrs) do
    if (!Map.has_key? attrs, :email) do
      nil
    else
      Network.get_first_node!(:email, attrs.email)
    end
  end

  def upsert_on_email(attrs) do
    node = node_if_email(attrs)
    if (node) do
        Network.update_node node, attrs
    else
      Network.create_node attrs
    end
  end

  @doc """
  Link node parents using index

  ## Examples
  iex> alias Igwet.DataImport
  iex> alias Igwet.Network
  iex> {:ok, parent} = Network.create_node %{name: "parent", key: "is.parent", meta: %{parent_id: nil}}
  iex> {:ok, child} = Network.create_node %{name: "child", key: "is.child", meta: %{parent_id: nil}}
  iex> pmap = %{node_index: 1, parent_index: nil, node: parent}
  iex> cmap = %{node_index: 2, parent_index: 1, node: child}
  iex> result = DataImport.link_nodes([pmap, cmap])
  iex> length(result)
  2
  iex> Enum.at(result, 0).meta.parent_id
  nil
  iex> Enum.at(result, 1).meta.parent_id
  parent.id

  """


  def link_nodes(node_map) do
    for entry <- node_map do
      #Logger.warn("link_nodes.entry: #{inspect(entry)}")
      if (entry.parent_index) do
        p_entry = node_map |> Enum.find(fn e -> e.node_index == entry.parent_index end)
        add_parent(entry.node, p_entry.node)
      else
        entry.node
      end
    end
  end

  defp add_parent(node, parent) do
    attrs = %{meta: %{parent_id: parent.id}}
    {:ok, new_node} = Network.update_node node, attrs
    new_node
  end

end
