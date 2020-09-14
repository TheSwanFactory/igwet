defmodule Igwet.Network do
  @moduledoc """
  The Network context.
  """

  require Logger
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

      :phone ->
        where(first, phone: ^value)

      _ ->
        raise "get_first_node!: Unknown field `#{field}`"
    end
    |> Repo.one!()
  end

  @doc """
  Find all nodes where _field_ matches _pattern_

  ## Examples
      iex> alias Igwet.Network
      iex> Network.get_nodes_like_key(".%")
      [%Node{}]

  """

  def get_nodes_like_key(pattern) do
    from(a in Node,
      order_by: [asc: :inserted_at],
      where: like(a.key, ^pattern)
    ) |> Repo.all
  end

  @doc """
  Find all nodes where _field_ NOT matches _pattern_

  ## Examples
      iex> alias Igwet.Network
      iex> Network.get_nodes_unlike_key(".%")
      [%Node{}]

  """

  def get_nodes_unlike_key(pattern) do
    from(a in Node,
      order_by: [asc: :inserted_at],
      where: not(like(a.key, ^pattern))
    ) |> Repo.all
  end

  @doc """
  Get predicate.  Create if missing.

  """
  def get_predicate(value) do
    first = Node
            |> order_by([asc: :inserted_at])
            |> where([n], n.name == ^value)
            |> limit(1)
            |> Repo.one()
    if (!is_nil first) do
      first
    else
      {:ok, node} = create_node %{name: value, type: "predicate", key: ".usr" <> "+" <> value}
      node
    end
  end

  defp key_from_string(string) do
    String.replace(string, ~r/\W+/, "_")
  end

  @doc """
  Get member of this group.  Create or associate if missing.

  """
  def get_member_for_email(email, group) do
    node = Node
            |> order_by([asc: :inserted_at])
            |> where([n], n.email == ^email)
            |> limit(1)
            |> Repo.one()
    if (!is_nil node) do
      if (!node_in_group?(node, group)) do
        set_node_in_group(node, group)
      end
      node
    else
      name = email |> String.split("@") |> Enum.at(0)
      {:ok, node} = create_node %{
        name: name,
        email: email,
        type: "contact",
        key: key_from_string("#{group.key}+#{name}")
      }
      set_node_in_group(node, group)
      node
    end
  end

  @doc """
  Get contact by phone number.  Create if missing.

  """
  def get_contact_for_phone(number, stub) do
    node = Node
            |> order_by([asc: :inserted_at])
            |> where([n], n.phone == ^number)
            |> limit(1)
            |> Repo.one()
    if (!is_nil node) do
      node
    else
      name = "#{stub}#{number}"
      {:ok, node} = create_node %{
        name: name,
        phone: number,
        type: "contact",
        key: key_from_string("sms.contact+#{name}")
      }
      node
    end
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
    in_node = get_predicate("in")
    !is_nil find_edge(node, in_node, group)
  end

  @doc """
  Check if subject and object related via predicate.

  ## Examples

      iex> find_edge(subject, predicate, object)
      true

  """
  def find_edge(subject, predicate, object) do
    Edge
      |> order_by([asc: :inserted_at])
      |> where([e],
        e.subject_id == ^subject.id and e.object_id == ^object.id and
        (e.predicate_id == ^predicate.id or e.relation == ^predicate.name)
      )
      |> Repo.one()
  end

  @doc """
  Relate subject and object via predicate.

  ## Examples

      iex> make_edge(subject, pred_name, object)
      true

  """

  def make_edge(subject, pred_name, object) do
    predicate = get_predicate(pred_name)
    create_edge(%{subject_id: subject.id, predicate_id: predicate.id, object_id: object.id})
  end

  @doc """
  Count over all nodes attending an event

  ## Examples

      iex> count_attendance(event)
      true

  """
  def count_attendance(event) do
    related_edges_for_object(event, "at")
    |> Enum.reduce(0, fn(edge, sum) ->
      #Logger.warn("count_attendance\n"<>inspect(edge))
      sum + String.to_integer("0#{edge.as}")
    end)
  end

  @doc """
  Count for this node attending an event

  ## Examples

      iex> member_attendance(member, event)
      true

  """
  def member_attendance(member, event) do
    at = get_predicate("at")
    edge = find_edge(member, at, event)
    if (edge) do
      String.to_integer("0#{edge.as}")
    else
      0
    end
  end

  @doc """
  Set count of node attending an event

  ## Examples

      iex> make_attendance(count, node, event)
      true

  """

  def attend!(count, node, event) do
    at = get_predicate("at")
    current = count_attendance(event)
    existing = find_edge(node, at, event)
    offset = if (!existing), do: 0, else: String.to_integer("0#{existing.as}")
    new_total = current + count - offset

    #Logger.warn "attend!new_total #{new_total} vs event.size #{event.size}"
    cond do
      new_total > event.size ->
        {:error, current}
      existing ->
        update_edge existing, %{as: "#{count}"}
        {:ok, new_total}
      true ->
        {:ok, _edge} = create_edge %{
          subject_id: node.id,
          predicate_id: at.id,
          object_id: event.id,
          as: "#{count}"
        }
        {:ok, new_total}
    end
  end

  @doc """
  Associate a member with a group.
  Set 'as' to initials, update if not unique,
  """
  def set_node_in_group(node, group) do
    if (node_in_group?(node, group)) do
      false
    else
      make_edge(node, "in", group)
    end
  end

  @doc """
  Remove a member a group.
  """
  def unset_node_in_group(node, group) do
    in_node = get_predicate("in")
    edge = find_edge(node, in_node, group)
    if (!edge) do
      false
    else
      delete_edge(edge)
    end
  end

  @doc """
  Return all objects for that predicate.

  ## Examples

      iex> objects_for_predicate("in")
      [%Igwet.Network.Node{}]

  """
  def objects_for_predicate(predicate) do
    in_node = get_predicate(predicate)

    Edge
    |> order_by([asc: :inserted_at])
    |> where([e], e.predicate_id == ^in_node.id)
    |> preload([:object])
    |> Repo.all()
    |> Enum.map(& &1.object)
    |> Enum.uniq
  end

  @doc """
  Return all objects for that predicate.

  ## Examples

      iex> subjects_for_predicate("in")
      [%Igwet.Network.Node{}]

  """
  def subjects_for_predicate(predicate) do
    in_node = get_predicate(predicate)

    Edge
    |> order_by([asc: :inserted_at])
    |> where([e], e.predicate_id == ^in_node.id)
    |> preload([:subject])
    |> Repo.all()
    |> Enum.map(& &1.subject)
    |> Enum.uniq
  end

  @doc """
  Return all group nodes this node is in.

  ## Examples

      iex> node_groups(node)
      [%Igwet.Network.Node{},...]

  """
  def node_groups(node) do
    related_objects(node, "in")
  end

  @doc """
  Return all nodes that are a member of this group.

  ## Examples

      iex> node_members(node)
      [%Igwet.Network.Node{},...]

  """
  def node_members(node) do
    related_subjects(node, "in")
  end

  @doc """
  Return all subjects with that relation to this object.

  ## Examples

      iex> related_subjects(object, pred_name)
      [%Igwet.Network.Node{},...]

  """
  def related_subjects(object, pred_name) do
    related_edges_for_object(object, pred_name)
    |> Enum.map(& &1.subject)
  end

  def related_edges_for_object(object, pred_name) do
    pred_node = get_predicate(pred_name)
    Edge
    |> order_by([asc: :inserted_at])
    |> where([e], e.object_id == ^object.id and e.predicate_id == ^pred_node.id)
    |> preload([:subject])
    |> Repo.all()
  end

  @doc """
  Return all objects with that subject has that relation to

  ## Examples

      iex> related_objects(subject, pred_name)
      [%Igwet.Network.Node{},...]

  """
  def related_objects(subject, pred_name) do
    pred_node = get_predicate(pred_name)

    edges =
      Edge
      |> order_by([asc: :inserted_at])
      |> where([e], e.subject_id == ^subject.id and e.predicate_id == ^pred_node.id)
      |> preload([:object])
      |> Repo.all()

    Enum.map(edges, & &1.object)
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
  Returns the type of a node.

  ## Examples

      iex> Network.get_type(node)

  """
  def get_type(node) do
    if (node.type) do
      node.type
    else
      get_type_edge(node)
    end
  end

  def get_type_edge(node) do
      first = related_objects(node, "type")
              |> Enum.at(0)
      if (first) do
        first.name
      else
        nil
      end
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
    case Repo.insert(Node.changeset(%Node{}, attrs)) do
      {:ok, node} ->
        {:ok, node}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  def create_event(attrs \\ %{}) do
    case create_node(attrs) do
      {:ok, event} ->
        is_event = get_predicate("event")
        make_edge(event, "type", is_event)
        group = get_node!(event.meta.parent_id)
        make_edge(event, "for", group)
        {:ok, event}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
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
  Updated membershp based on form attributes.
  """
  def update_members(group, members, attrs) do
    ids = Enum.map(members, & &1.id)
    Logger.debug("** update_members.ids "<> inspect(ids))
    Logger.debug("** update_members.attrs "<> inspect(attrs))

    for {key, value} <- attrs do
      Logger.debug("*** update_members: "<> inspect(key))
      if k = Regex.run(~r/member:(.*)/, key, capture: :all_but_first) do
        Logger.debug("*** update_members "<>inspect(k)<>" = "<>inspect(value))
        if !Enum.member?(ids, value) do
          Logger.debug("*** update_members:set_node_in_group "<>inspect(value))
          node = get_node!(value)
          set_node_in_group(node, group)
        end
      end
    end
    obsolete = ids -- Map.values(attrs)
    for value <- obsolete do
      Logger.debug("*** update_members:UNset_node_in_group "<>inspect(value))
      node = get_node!(value)
      unset_node_in_group(node, group)
    end
  end

  @doc """
  Get initials.
  Set if not present
  """
  def get_initials(node) do
    if (node.initials) do
      node.initials
    else
      initials = String.split(node.name, " ")
      |> Enum.map(&String.first/1)
      |> Enum.join("")
      |> String.downcase()
      update_node(node, %{initials: initials})
      initials
    end
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
