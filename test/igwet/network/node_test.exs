defmodule Igwet.NetworkTest.Node do
  require Logger
  use Igwet.DataCase
  alias Igwet.Network
  alias Igwet.Network.Node
  alias Igwet.Scheduler
  import Crontab.CronExpression
  doctest Igwet.Network.Node

  @valid_attrs %{
    about: "some about",
    email: "some email",
    key: "some.key",
    name: "some name",
    phone: "+14085551212",
    type: "type.name",
  }
  @update_attrs %{
    about: "next about",
    email: "next email",
    key: "next key",
    name: "next name",
    phone: "+17765551212",
  }
  @invalid_attrs %{about: nil, email: nil, key: nil, name: nil, phone: nil}

  @event_attrs %{
    about: "event details",
    date: %{year: 2020, month: 4, day: 23, hour: 2, minute: 3},
    key: "event.key",
    meta: %{duration: 90, parent_id: nil, recurrence: 7},
    name: "4/23: event name 8:35am",
    phone: "+12105551212",
    size: 5,
    timezone: "US/Pacific",
    type: "event",
  }

  @twilio_params 	%{"AccountSid" => "ACSID", "ApiVersion" => "2010-04-01", "Body" => "ThisIsTheEnd", "From" => "+14085551212", "FromCity" => "SAN JOSE", "FromCountry" => "US", "FromState" => "CA", "FromZip" => "95076", "MessageSid" => "MessageSid12345", "MessagingServiceSid" => "MGSID", "NumMedia" => "0", "NumSegments" => "1", "SmsMessageSid" => "SmsMessageSid12345", "SmsSid" => "SmsSid12345", "SmsStatus" => "received", "To" => "+12105551212", "ToCity" => "SAN ANTONIO", "ToCountry" => "US", "ToState" => "TX", "ToZip" => "78215"}

  def node_fixture(attrs \\ %{}) do
    {:ok, node} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Network.create_node()
    node
  end

  describe "get node" do
    test "get_first_node!/1 returns first node" do
      node = node_fixture()
      node_fixture(%{key: "different key"})
      assert Network.get_first_node!(:name, node.name).id == node.id
      assert Network.get_first_node!(:phone, node.phone).id == node.id
    end

    test "get_first_node_named!/1 raises if no node with that name" do
      assert_raise Ecto.NoResultsError, fn -> Network.get_first_node!(:name, "unnamed") end
    end

    test "list_nodes/0 returns all nodes" do
      node = node_fixture()
      assert Enum.member?(Network.list_nodes(), node)
    end

    test "get_node!/1 returns the node with given id" do
      node = node_fixture()
      next_node = Network.get_node!(node.id)
      assert next_node.id == node.id
    end

    test "create_node/1 with valid data creates a node" do
      assert {:ok, %Node{} = node} = Network.create_node(@valid_attrs)
      assert node.about == "some about"
      assert node.email == "some email"
      assert node.key == "some.key"
      assert node.name == "some name"
      assert node.phone == @valid_attrs.phone
    end

    test "create_node/1 with type name sets type" do
      assert {:ok, %Node{} = node} = Network.create_node(@valid_attrs)
      assert "type.name" == node.type
    end
  end

  describe "modify node" do
    test "create_node/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Network.create_node(@invalid_attrs)
    end

    test "update_node/2 with valid data updates the node" do
      node = node_fixture()
      assert {:ok, node} = Network.update_node(node, @update_attrs)
      assert %Node{} = node
      assert node.about == "next about"
      assert node.email == "next email"
      assert node.key == "next key"
      assert node.name == "next name"
      assert node.phone == @update_attrs.phone
    end

    test "update_node/2 with invalid data returns error changeset" do
      node1 = node_fixture()
      node = Network.get_node!(node1.id)
      assert {:error, %Ecto.Changeset{}} = Network.update_node(node, @invalid_attrs)
      assert node == Network.get_node!(node.id)
    end

    test "delete_node/1 deletes the node" do
      node = node_fixture()
      assert {:ok, %Node{}} = Network.delete_node(node)
      assert_raise Ecto.NoResultsError, fn -> Network.get_node!(node.id) end
    end

    test "change_node/1 returns a node changeset" do
      node = node_fixture()
      assert %Ecto.Changeset{} = Network.change_node(node)
    end
  end

  describe "twilio webhook" do
    setup [:create_event]
    test "get_contact_for_phone/2 gets node if exists" do
      contact = Network.get_contact_for_phone(@twilio_params["From"], @twilio_params["FromCity"])
      assert @twilio_params["From"] == contact.phone
      assert "type.name" == contact.type
    end

    test "get_contact_for_phone/2 creates contact if missing" do
      phone = "+14325551212"
      contact = Network.get_contact_for_phone(phone, @twilio_params["FromCity"])
      assert phone == contact.phone
      assert contact.name =~ @twilio_params["FromCity"]
      assert "contact" == contact.type
    end

  end

  describe "rsvp node" do
    setup [:create_event]

    test "get_member_for_email/2 creates node if needed", %{group: group} do
      email = "test@example.com"
      member = Network.get_member_for_email(email, group)
      assert !is_nil member
      assert email == member.email
      assert "test" == member.name
    end

    test "attend!/3 accepts strings", %{node: node, event: event} do
      #Logger.warn inspect(event)
      count = 3
      string = "#{count}"
      result = Network.attend!(string, node, event)
      assert result == {:ok, count}
      assert count == Network.count_attendance(event)
    end

    test "attend!/3 accepts 'Zoom'", %{node: node, event: event} do
      #Logger.warn inspect(event)
      count = 0
      string = "Zoom"
      result = Network.attend!(string, node, event)
      assert result == {:ok, count}
      assert count == Network.count_attendance(event)
    end


    test "attend!/3 returns :ok if enough open", %{node: node, event: event} do
      #Logger.warn inspect(event)
      count = 3
      result = Network.attend!(count, node, event)
      assert result == {:ok, count}
      assert count == Network.count_attendance(event)
    end

    test "attend!/3 returns :error if NOT enough open", %{node: node, event: event, next: next} do
      result = Network.attend!(event.size, node, event)
      assert result == {:ok, event.size}
      result = Network.attend!(1, next, event)
      assert result == {:error, event.size}
    end

    test "attend!/3 updates count if already exists", %{node: node, event: event} do
      result = Network.attend!(event.size, node, event)
      assert result == {:ok, event.size}
      result = Network.attend!(1, node, event)
      assert result == {:ok, 1}
      assert 1 == Network.count_attendance(event)
    end

    test "member_attendance/2 tracks each attendee's count", %{node: node, event: event, next: next} do
      node_count = 2
      Network.attend!(node_count, node, event)
      assert node_count == Network.member_attendance(node, event)

      next_count = 3
      Network.attend!(next_count, next, event)
      assert next_count == Network.member_attendance(next, event)

      assert 5 == Network.count_attendance(event)
    end

    test "related_subjects/2 returns attendees", %{node: node, event: event, next: next} do
      Network.attend!(1, node, event)
      Network.attend!(3, next, event)
      attendees = Network.related_subjects(event, "at")
      assert Enum.count(attendees) == 2
    end
  end

  describe "event" do
    setup [:create_event]
    test "next", %{node: node, event: event} do
      {:ok, next} = Network.next_event(event, node)
      #Logger.warn(inspect(next))
      assert next
      assert next.key == "some.key.4en8_2020-04-30"
      assert next.name =~ "04-30: event"
    end

    test "last found", %{node: node, event: event} do
      :timer.sleep(1000)
      {:ok, _next} = Network.next_event(event, node)
      all = Network.get_nodes_like_key("some.key%")
      assert length(all) == 2
      last = Network.last_event!("some.key")
      assert last
      assert last.key == "some.key.4en8_2020-04-30"
      assert last.name =~ "04-30: event"
    end

    test "upcoming", %{event: event} do
      upcoming = Network.upcoming_event!(event)
      assert upcoming
      assert upcoming. key =~ "next key"
      {:ok, now} = DateTime.now(upcoming.timezone)
      {:ok, uptime} = DateTime.from_naive(upcoming.date, upcoming.timezone)
      assert :lt == DateTime.compare(now, uptime)

      again = Network.upcoming_event!(upcoming)
      assert again == upcoming
    end

    test "node_cron", %{event: event} do
      cron = Scheduler.node_cron(event)
      assert !is_nil cron
      assert ~e[3 2 * * * *] == cron
    end

    test "node_job", %{event: event} do
      job = Scheduler.node_job(event)
      assert !is_nil job
      assert :ok == job
    end
  end

  defp create_event(_) do
    node = node_fixture()
    next = node_fixture(%{name: "next", key: "com.next"})
    group = node_fixture(@update_attrs)
    event = @event_attrs
            |> put_in([:meta, :parent_id], group.id)
            |> node_fixture()
    %{node: node, group: group, event: event, next: next}
  end
end
