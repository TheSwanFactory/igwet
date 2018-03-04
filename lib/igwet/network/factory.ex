defmodule Igwet.Network.Factory do
  @moduledoc """
  Helper methods for creating Nodes and Edges using appropriate keys
  """

  import Ecto.Query, warn: false
  alias Igwet.Repo, warn: false
  alias Igwet.Network, warn: false
  alias Igwet.Network.Node, warn: false
  alias Igwet.Network.Edge, warn: false

  @doc """
  Converts an arbitrary string into a suitable key

  ## Examples
      iex> alias Igwet.Network.Factory
      iex> Factory.key_from_string("Hello, World! ")
      "hello_world"

  """

  def key_from_string(string) do
    string
    |> String.trim
    |> String.downcase
    |> String.replace(~r/\W+/, "_")
    |> String.trim("_")
  end

  @doc """
  Converts url into a reverse-dns name

  ## Examples
      iex> alias Igwet.Network.Factory
      iex> Factory.key_from_url("https://www.igwet.com")
      ".com.igwet"

  """

  def key_from_url(string) do
    %{host: host} = URI.parse(string)
    host
    |> String.split(".")
    |> Enum.reject(fn(w) -> w == "www" end)
    |> Enum.concat([" "])
    |> Enum.reverse
    |> Enum.join(".")
    |> String.trim
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
      "sys+me"
      iex> next = Factory.create_child_node!(%{name: "u", in: "me"})
      iex> next.key
      "sys+me+u"
      iex> Igwet.Network.node_in_group?(next, node)
      true


  """
  def create_child_node!(attrs \\ %{}) do
    type_node = if Map.has_key?(attrs, :type) do
      Network.get_first_node_named!(attrs.type)
    end
    in_node = if Map.has_key?(attrs, :in) do
      Network.get_first_node_named!(attrs.in)
    end
    in_key = if in_node do
      in_node.key
    else
      "sys"
    end
    key = "#{in_key}+#{key_from_string(attrs.name)}"
    attrs = Map.put attrs, :key, key
    {:ok, node} = Network.create_node(attrs)
    if in_node do
    end
    node
  end

end
