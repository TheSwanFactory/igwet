defmodule Igwet.Network do
  @moduledoc """
  The Network context.
  """

  require Logger
  import Ecto.Query, warn: false
  alias Igwet.Repo
  alias Igwet.Network.Node
  alias Igwet.Network.Edge

  @sec_per_day 24 * 60 * 60
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
        email = String.downcase(value)
        where(first, email: ^email)

      :about -> where(first, about: ^value)
      :initials -> where(first, initials: ^value)
      :key -> where(first, key: ^value)
      :name -> where(first, name: ^value)
      :phone -> where(first, phone: ^value)
      _ -> raise "get_first_node! can not search on field `#{field}`"
    end
    |> Repo.one!()
  end

def get_first_email(email) do
    from(
      Node,
      order_by: [asc: :inserted_at],
      limit: 1
    )
    |> where(email: ^email)
    |> Repo.one()
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
      iex> Network.get_nodes_of_type("contact")
      [%Node{}]

  """

  def get_nodes_of_type(pattern) do
    from(a in Node,
      order_by: [asc: :inserted_at],
      where: like(a.type, ^pattern)
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
  def get_member_for_email(email_raw, group) do
    email = String.downcase(email_raw)
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
    !is_nil find_edge(node, "in", group)
  end

  @doc """
  Check if subject and object related via predicate.

  ## Examples

      iex> find_edge(subject, predicate, object)
      true

  """
  def find_edge(subject, relation, object) do
    predicate = get_predicate(relation)
    Edge
      |> order_by([asc: :inserted_at])
      |> where([e],
        e.subject_id == ^subject.id and e.object_id == ^object.id and
        (e.predicate_id == ^predicate.id or e.relation == ^relation)
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
    create_edge(%{subject_id: subject.id, relation: pred_name, object_id: object.id})
  end

  defp number_in_person(value) do
    if (value == "Zoom"), do: 0, else: String.to_integer("0#{value}")
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
      sum + number_in_person(edge.as)
    end)
  end

  @doc """
  Count for this node attending an event

  ## Examples

      iex> member_attendance(member, event)
      true

  """
  def member_attendance(member, event) do
    edge = find_edge(member, "at", event)
    #Logger.warn "member_attendance #{member.name} @ #{event.name}:\n#{inspect(edge)}"
    if (edge) do
      number_in_person(edge.as)
    else
      -1
    end
  end

  @doc """
  Set count of node attending an event

  ## Examples

      iex> make_attendance(count, node, event)
      true

  """

  def attend!(result, member, event) do
    count = number_in_person(result)
    current = count_attendance(event)
    existing = find_edge(member, "at", event)
    #Logger.warn "attend!existing #{inspect(existing)}"
    offset = if (!existing), do: 0, else: number_in_person(existing.as)
    new_total = current + count - offset

    #Logger.warn "attend!new_total #{new_total} vs event.size #{event.size}"
    cond do
      new_total > event.size ->
        {:error, current}
      existing ->
        update_edge existing, %{as: "#{result}", relation: "at"}
        {:ok, new_total}
      true ->
        {:ok, _edge} = create_edge %{
          subject_id: member.id,
          relation: "at",
          object_id: event.id,
          as: "#{count}"
        }
        #Logger.warn "attend!edge #{inspect(edge)}"
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
    edge = find_edge(node, "in", group)
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
  def objects_for_predicate(relation) do
    predicate = get_predicate(relation)
    Edge
    |> order_by([asc: :inserted_at])
    |> where([e], e.predicate_id == ^predicate.id or e.relation == ^relation)
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
  def subjects_for_predicate(relation) do
    predicate = get_predicate(relation)
    Edge
    |> order_by([asc: :inserted_at])
    |> where([e], e.predicate_id == ^predicate.id or e.relation == ^relation)
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
    |> Enum.sort_by(& &1.name)
  end

  def related_edges_for_object(object, pred_name) do
    pred_node = get_predicate(pred_name)
    Edge
    |> order_by([asc: :inserted_at])
    |> where([e], e.object_id == ^object.id and (e.predicate_id == ^pred_node.id or e.relation == ^pred_name))
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
      |> where([e], e.subject_id == ^subject.id and (e.predicate_id == ^pred_node.id or e.relation == ^pred_name))
      |> preload([:object])
      |> Repo.all()

    edges
    |> Enum.map(& &1.object)
    |> Enum.sort_by(& &1.name)
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
  def get_node!(id) do
    Repo.get!(Node, id)
  end

  @doc """
  Gets a single node based on its unique key

  Raises `Ecto.NoResultsError` if the Node does not exist.

  ## Examples

      iex> keys = Application.get_env(:igwet, :seed_keys)
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
    params = Map.put(attrs, "type", "event")
    case create_node(params) do
      {:ok, event} ->
        group = get_node!(event.meta.parent_id)
        make_edge(event, "for", group)
        {:ok, event}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Find the most recent event partially matching this key

  """
  def last_event!(event_key) do
    pattern = "%#{event_key}%"
    from(a in Node,
      order_by: [desc: :inserted_at],
      where: like(a.key, ^pattern),
      limit: 1
    ) |> Repo.one!()
  end

  @doc """
  Next event.  Create an event _recurrence_ days after this one

  """
  def pad(number) do
    number |> Integer.to_string |> String.pad_leading(2, "0")
  end

  def next_event(event, group, repeat \\ 1) do
    next_week = NaiveDateTime.add(event.date, event.meta.recurrence * @sec_per_day * repeat)
    prefix = "#{pad(next_week.month)}-#{pad(next_week.day)}"
    suffix = "#{next_week.year}-#{prefix}"
    key = group.key <> "." <> get_initials(event) <> "_" <> suffix

    split = String.split(event.name, ": ")
    name = if (length(split) == 2) do
      "#{prefix}: #{Enum.at(split, 1)}"
    else
      "#{prefix}: #{event.name}"
    end

    details = Map.from_struct(event.meta)
    hidden = Map.merge(details, %{hidden: true})
    update_node(event, %{meta: hidden})

    unhidden = Map.merge(details, %{hidden: false})
    event
    |> Map.merge(%{date: next_week, key: key, meta: unhidden, name: name})
    |> Map.delete(:id)
    |> Map.from_struct()
    |> Map.new(fn {key, value} -> {Atom.to_string(key), value} end)
    |> create_event()
  end

  @doc """
  Latest event.  Create or find an recurred event after today

  """
  def upcoming_event!(event) do
    group = if (event.meta && event.meta.parent_id && event.meta.recurrence > 0) do
       get_node!(event.meta.parent_id)
    else
      raise "upcoming_event!: not recurring event `#{inspect(event)}`"
    end
    {:ok, now} = DateTime.now(event.timezone)
    {:ok, current} = DateTime.from_naive(event.date, event.timezone)

    delta = DateTime.diff(now, current)/(@sec_per_day * event.meta.recurrence)
    if (delta < 0) do
      event
    else
      {:ok, upcoming} = next_event(event, group, trunc(delta) + 1)
      upcoming
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

    for {key, value} <- attrs do
      if Regex.run(~r/member:(.*)/, key, capture: :all_but_first) do
        if !Enum.member?(ids, value) do
          node = get_node!(value)
          set_node_in_group(node, group)
        end
      end
    end
    obsolete = ids -- Map.values(attrs)
    for value <- obsolete do
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
