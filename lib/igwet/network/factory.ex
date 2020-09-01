defmodule Igwet.Network.Factory do
  @moduledoc """
  Helper methods for creating Nodes and Edges using appropriate keys
  """

  # require IEx; #IEx.pry
  alias Igwet.Repo
  alias Igwet.Network
  alias Igwet.Network.Edge

  @host_key "host"
  @in_key "in"
  @sys_key ".sys"
  @type_key "type"

  @doc """
  Converts an arbitrary string into a suitable key

  ## Examples
      iex> alias Igwet.Network.Factory
      iex> Factory.key_from_string("Hello, World! ")
      "hello_world"

  """

  def key_from_string(string) do
    string
    |> String.trim()
    |> String.downcase()
    |> String.replace(~r/\W+/, "_")
    |> String.trim("_")
  end

  @doc """
  Converts url into a reverse-dns name

  ## Examples
      iex> alias Igwet.Network.Factory
      iex> Factory.key_from_url("https://www.igwet.com")
      "com.igwet"

  """

  def key_from_url(string) do
    %{host: host} = URI.parse(string)

    host
    |> String.split(".")
    |> Enum.reject(fn w -> w == "www" end)
    |> Enum.reverse()
    |> Enum.join(".")
    |> String.trim()
  end

  @doc """
  Generates appropriate key from list of attributes

  ## Examples
      iex> alias Igwet.Network.Factory
      iex> Factory.key_from_attrs(%{name: "me", url: "https://www.igwet.com", type: "host"})
      "com.igwet"

  """

  def key_from_attrs(attrs) do
    if Map.has_key?(attrs, :type) and Map.has_key?(attrs, :url) and attrs.type == "host" do
      key_from_url(attrs.url)
    else
      key_from_string(attrs.name)
    end
  end

  @doc """
  Creates edge using keyword for predicate

  """

  def create_relation!(subject, object, keyword) do
    Repo.insert!(%Edge{
      subject: subject,
      object: object,
      predicate: Network.get_predicate(keyword)
    })
  end

  @doc """
  Creates a node of a given type, generating key if necessary

  ## Examples

      iex> alias Igwet.Network.Factory
      iex> Factory.create_child_node!(%{})
      ** (KeyError) key :name not found in: %{}

      iex> alias Igwet.Network.Factory
      iex> node = Factory.create_child_node!(%{name: "me"})
      iex> node.key
      ".sys+me"
      iex> next = Factory.create_child_node!(%{name: "u", in: "me"})
      iex> next.key
      ".sys+me+u"
      iex> Igwet.Network.node_in_group?(next, node)
      true


  """
  def create_child_node!(attrs \\ %{}) do
    type_node =
      if Map.has_key?(attrs, :type) do
        Network.get_first_node!(:name, attrs.type)
      end

    in_node =
      if Map.has_key?(attrs, :in) do
        Network.get_first_node!(:name, attrs.in)
      end

    in_key = if in_node, do: in_node.key, else: @sys_key
    node_key = key_from_attrs(attrs)

    key =
      if attrs[:type] == @host_key do
        node_key
      else
        "#{in_key}+#{node_key}"
      end

    attrs = Map.put(attrs, :key, key)
    {:ok, node} = Network.create_node(attrs)
    if in_node, do: create_relation!(node, in_node, @in_key)
    if type_node, do: create_relation!(node, type_node, @type_key)
    node
  end
end
