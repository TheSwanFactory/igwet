defmodule Igwet.Network do
  @moduledoc """
  The Network context.
  """

  import Ecto.Query, warn: false
  alias Igwet.Repo
  alias Igwet.Network.Node
  alias Igwet.Network.Edge

  @doc """
  Find first node matching a name/email/key

  ## Examples

      iex> get_first_node!(:email, "ernest.prabhakar@gmail.com")
      %Node{}

  """
  def get_first_node!(field, value) do
    first =
      from(
        Node,
        order_by: [asc: :inserted_at],
        limit: 1
      )

    case field do
      :email ->
        where(first, email: ^value)

      :key ->
        where(first, key: ^value)

      :name ->
        where(first, name: ^value)

      _ ->
        raise "get_first_node!: Unknown field `#{field}`"
    end
    |> Repo.one!()
  end

  @doc """
  Check if node is in site admin group.

  ## Examples

      iex> node_is_admin?(node)
      true

  """
  def node_is_admin?(node) do
    group = get_first_node!(:name, "admin")
    node_in_group?(node, group)
  end

  @doc """
  Check if nodes have an in-relation.

  ## Examples

      iex> node_in_group?(node, group)
      true

  """
  def node_in_group?(node, group) do
    in_node = get_first_node!(:name, "in")
    edge_exists?(node, in_node, group)
  end

  @doc """
  Check if subject and object related via predicate.

  ## Examples

      iex> edge_exists?(subject, predicate, object)
      true

  """
  def edge_exists?(subject, predicate, object) do
    edge =
      Edge
      |> where(
        [e],
        e.subject_id == ^subject.id and e.predicate_id == ^predicate.id and
          e.object_id == ^object.id
      )
      |> Repo.one()

    edge != nil
  end

  @doc """
  Return all objects for that predicate.

  ## Examples

      iex> objects_for_predicate("in")
      [%Igwet.Network.Node{}]

  """
  def objects_for_predicate(predicate) do
    in_node = get_first_node!(:name, predicate)

    edges =
      Edge
      |> where([e], e.predicate_id == ^in_node.id)
      |> preload([:object])
      |> Repo.all()

    Enum.map(edges, & &1.object)
  end

  @doc """
  Return all group nodes this node is in.

  ## Examples

      iex> node_groups(node)
      [%Igwet.Network.Node{},...]

  """
  def node_groups(node) do
    in_node = get_first_node!(:name, "in")

    edges =
      Edge
      |> where([e], e.subject_id == ^node.id and e.predicate_id == ^in_node.id)
      |> preload([:object])
      |> Repo.all()

    Enum.map(edges, & &1.object)
  end

  @doc """
  Return all nodes that are a member of this group.

  ## Examples

      iex> node_members(node)
      [%Igwet.Network.Node{},...]

  """
  def node_members(node) do
    in_node = get_first_node!(:name, "in")

    edges =
      Edge
      |> where([e], e.object_id == ^node.id and e.predicate_id == ^in_node.id)
      |> preload([:subject])
      |> Repo.all()

    Enum.map(edges, & &1.subject)
  end

  @doc """
  Returns the list of nodes.

  ## Examples

      iex> list_nodes()
      [%Igwet.Network.Node{}, ...]

  """
  def list_nodes do
    Repo.all(Node)
  end

  @doc """
  Gets a single node.

  Raises `Ecto.NoResultsError` if the Node does not exist.

  ## Examples

      iex> get_node!(123)
      %Node{}

      iex> get_node!(456)
      ** (Ecto.NoResultsError)

  """
  def get_node!(id), do: Repo.get!(Node, id)

  @doc """
  Gets a single node based on its unique key

  Raises `Ecto.NoResultsError` if the Node does not exist.

  ## Examples

      iex> keys = Application.get_env(:iget, :seed_keys)
      iex> get_node_by_key!(keys[:in])
      %Node{}

      iex> Network.get_node_by_key!("")
      ** (Ecto.NoResultsError)

  """

  def get_node_by_key!(key) do
    Node |> where([n], n.key == ^key) |> Repo.one!()
  end

  @doc """
  Creates a node.

  ## Examples

      iex> create_node(%{field: value})
      {:ok, %Node{}}

      iex> create_node(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_node(attrs \\ %{}) do
    %Node{}
    |> Node.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a node of a given type, generating key if necessary

  ## Examples

      iex> create_typed_node(%{field: value})
      {:ok, %Node{}}


  """
  def create_typed_node!(attrs \\ %{}) do
    %{key: key, type: type} = attrs

    if type == nil do
      {:error, %Ecto.Changeset{}}
    else
      type_node = get_first_node!(:name, type)

      new_attrs =
        if key == nil do
          type_key = type_node.key
          name_key = key_from_string(attrs["name"])
          key = "#{type_key}.#{name_key}"
          %{attrs | key: key}
        else
          attrs
        end

      {:ok, node} = create_node(new_attrs)
      node
    end
  end

  defp key_from_string(string) do
    String.replace(string, ~r/\W+/, "_")
  end

  @doc """
  Updates a node.

  ## Examples

      iex> update_node(node, %{field: new_value})
      {:ok, %Node{}}

      iex> update_node(node, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_node(%Node{} = node, attrs) do
    node
    |> Node.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Node.

  ## Examples

      iex> delete_node(node)
      {:ok, %Node{}}

      iex> delete_node(node)
      {:error, %Ecto.Changeset{}}

  """
  def delete_node(%Node{} = node) do
    Repo.delete(node)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking node changes.

  ## Examples

      iex> change_node(node)
      %Ecto.Changeset{source: %Node{}}

  """
  def change_node(%Node{} = node) do
    Node.changeset(node, %{})
  end

  @doc """
  Returns the list of edges.

  ## Examples

      iex> list_edges()
      [%Igwet.Network.Edge{}, ...]

  """
  def list_edges do
    Repo.all from e in Edge, preload: [:subject, :predicate, :object]
  end

  @doc """
  Gets a single edge.

  Raises `Ecto.NoResultsError` if the Edge does not exist.

  ## Examples

      iex> get_edge!(123)
      %Edge{}

      iex> get_edge!(456)
      ** (Ecto.NoResultsError)

  """
  def get_edge!(id) do
    Edge
    |> Repo.get!(id)
    |> Repo.preload([:subject, :predicate, :object])
  end

  @doc """
  Creates a edge.

  ## Examples

      iex> create_edge(%{field: value})
      {:ok, %Edge{}}

      iex> create_edge(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_edge(attrs \\ %{}) do
    %Edge{}
    |> Edge.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a edge.

  ## Examples

      iex> update_edge(edge, %{field: new_value})
      {:ok, %Edge{}}

      iex> update_edge(edge, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_edge(%Edge{} = edge, attrs) do
    edge
    |> Edge.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Edge.

  ## Examples

      iex> delete_edge(edge)
      {:ok, %Edge{}}

      iex> delete_edge(edge)
      {:error, %Ecto.Changeset{}}

  """
  def delete_edge(%Edge{} = edge) do
    Repo.delete(edge)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking edge changes.

  ## Examples

      iex> change_edge(edge)
      %Ecto.Changeset{%Igwet.Network.Edge{}}

  """
  def change_edge(%Edge{} = edge) do
    Edge.changeset(edge, %{})
  end

  alias Igwet.Network.Address

  @doc """
  Returns the list of addresses.

  ## Examples

      iex> list_addresses()
      [%Address{}, ...]

  """
  def list_addresses do
    Repo.all(Address)
  end

  @doc """
  Gets a single address.

  Raises `Ecto.NoResultsError` if the Address does not exist.

  ## Examples

      iex> get_address!(123)
      %Address{}

      iex> get_address!(456)
      ** (Ecto.NoResultsError)

  """
  def get_address!(id), do: Repo.get!(Address, id)

  @doc """
  Creates a address.

  ## Examples

      iex> create_address(%{field: "value"})
      {:ok, %Address{}}

      iex> create_address(%{field: "bad_value"})
      {:error, %Ecto.Changeset{}}

  """
  def create_address(attrs \\ %{}) do
    %Address{}
    |> Address.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a address.

  ## Examples
      iex> address = create_address(%{field: "value"})
      iex> update_address(address, %{field: "new_value"})
      {:ok, %Igwet.Network.Address{}}

      iex> update_address(address, %{field: "bad_value"})
      {:error, %Ecto.Changeset{}}

  """
  def update_address(%Address{} = address, attrs) do
    address
    |> Address.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Address.

  ## Examples

      iex> address = create_address(%{field: "value"})
      iex> delete_address(address)
      {:ok, %Address{}}

      iex> delete_address(address)
      {:error, %Ecto.Changeset{}}

  """
  def delete_address(%Address{} = address) do
    Repo.delete(address)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking address changes.

  ## Examples

      iex> address = create_address(%{field: "value"})
      iex> change_address(address)
      %Ecto.Changeset{%Address{}}

  """
  def change_address(%Address{} = address) do
    Address.changeset(address, %{})
  end
end
