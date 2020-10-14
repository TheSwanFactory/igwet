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
  iex> merged = DataImport.merge_key(%{}, group, 13)
  iex> merged.key =~ "is.group+013"
  true
  iex> merged.meta
  %{parent_id: group.id}

  """

  def merge_key(attrs, group, i) do
    count = length(Network.node_members(group)) + i
    suffix = count |> Integer.to_string |> String.pad_leading(3, "0")
    now = DateTime.to_unix(DateTime.utc_now())
    attrs
    |> Map.put(:key, "#{group.key}+#{suffix}.#{now}")
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
    map_list
    |> Enum.with_index()
    |> Enum.map(fn({attrs, i}) ->
      {:ok, node} = attrs
      |> merge_key(group, i)
      |> downcase_email()
      |> upsert_on_email()
      if (node.type == "contact") do
        Network.set_node_in_group(node, group)
      end
      %{node: node, node_index: attrs.index, parent_index: attrs.parent}
    end)
  end

  def downcase_email(attrs) do
    if (!Map.has_key? attrs, :email) do
      attrs
    else
      email = String.downcase(attrs.email)
      Map.put(attrs, :email, email)
    end
  end

  def node_if_email(attrs) do
    if (!Map.has_key? attrs, :email) do
      nil
    else
      Network.get_first_email(attrs.email)
    end
  end

  def upsert_on_email(attrs) do
    node = node_if_email(attrs)
    if (node) do
        Network.update_node node, attrs
    else
      attrs
      |> Map.put(:type, "contact")
      |> Network.create_node
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
      if (entry.parent_index) do
        p_entry = node_map |> Enum.find(fn e -> e.node_index == entry.parent_index end)
        if (p_entry) do
          add_parent(entry.node, p_entry.node)
        else
          entry.node
        end
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

  @doc """
  Full import
  """

  def csv_for_group(path, group) do
    if (path) do
      csv_map(path)
      |> upsert_nodes(group)
      |> link_nodes()
    end
  end

  @doc """
  Full import
  """

  # %Plug.Upload{content_type: "image/jpg", filename: "cute-kitty.jpg", path: "/var/folders/_6/xbsnn7tx6g9dblyx149nrvbw0000gn/T//plug-1434/multipart-558399-917557-1"}

  def check_upload(upload, group) do
    #Logger.warn("check_upload #{inspect(upload)}")
    if (upload && upload.path) do
      csv_for_group(upload.path, group)
    end
  end

end
