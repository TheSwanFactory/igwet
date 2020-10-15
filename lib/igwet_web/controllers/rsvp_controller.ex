# Sample email: http://bin.mailgun.net/b1748eea#7jmd

defmodule IgwetWeb.RsvpController do
  use IgwetWeb, :controller
  require Logger
  alias Igwet.Network
  alias Igwet.Network.Node
  alias Igwet.Network.Sendmail
  alias Igwet.Network.SMS
  alias Igwet.Admin.Mailer
  @max_rsvp 6
  @server "https://www.igwet.com"

  def index(conn, _params) do
    event = Network.get_predicate("event")
    nodes = Network.related_subjects(event, "type")
    conn
    |> assign(:current_user, nil)
    |> render("index.html", events: nodes)
  end

  def by_event(conn, %{"event_key" => event_key}) do
    event = Network.get_first_node!(:key, event_key)
    current = Network.count_attendance(event)
    changeset = Network.change_node(%Node{})
    attendees = Network.related_subjects(event, "at")

    conn
    |> assign(:current_user, nil)
    |> assign(:group, Network.get_node!(event.meta.parent_id))
    |> assign(:attendees, attendees)
    |> render("event.html", event: event, current: current, changeset: changeset)
  end

  def add_email(conn, %{"event_key" => event_key, "node" => params}) do
    path = rsvp_path(conn, :by_email, event_key, params["email"])
    conn
    |> assign(:count, nil)
    |> redirect(to: path)
  end

  def by_email(conn, %{"event_key" => event_key, "email" => email}) do
    event = Network.get_first_node!(:key, event_key)
    group = Network.get_node!(event.meta.parent_id)
    node = Network.get_member_for_email(email, group)
    current = Network.count_attendance(event)
    count = Network.member_attendance(node, event)
    open = event.size - current
    msg = if (open > 0), do: "", else: "Sorry: #{event.name} is already at its full capacity of #{event.size}"
    Logger.warn("by_email.open: #{open}\n[#{msg}]")
    conn
    |> put_flash(:error, msg)
    |> assign(:current_user, nil)
    |> assign(:group, group)
    |> assign(:node, node)
    |> assign(:node_count, count)
    |> render("email.html", event: event, current: current, open: min(open, @max_rsvp))
  end

  def by_count(conn, %{"event_key" => event_key, "email" => email, "count" => count}) do
    event = Network.get_first_node!(:key, event_key)
    group = Network.get_node!(event.meta.parent_id)
    node = Network.get_member_for_email(email, group)
    msg = case Network.attend!(count, node, event) do
      {:ok, total} ->
        "Added #{count} for #{node.name} <#{node.email}>. Now #{total} attending #{event.name}"
      {:error, current} ->
        "Error #{count}: already #{current} of total capacity #{event.size} attending #{event.name}"
    end
    #Logger.warn("by_count.count: #{count}")
    conn
    |> put_flash(:info, msg)
#    |> assign(:node, node)
#    |> assign(:node_count, count)
    |> redirect(to: rsvp_path(conn, :by_email, event_key, email))
  end

  def next_event(conn, %{"id" => id}) do
    event = Network.get_node!(id)
    group_id = event.meta.parent_id
    group = Network.get_node!(group_id)
    case Network.next_event(event, group) do
      {:ok, event} ->
        url = @server <> rsvp_path(conn, :by_event, event.key)
        SMS.group_event_message(group.phone, event.name, url)
        |> SMS.send_message()

        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:error, "Event creation failed.\n#{inspect(event)}")
        |> redirect(to: event_path(conn, :index))
    end
  end

  defp missing_group_email(conn, group) do
    msg = "Error: first enter a Group email in order to send RSVPs"
    conn
    |> put_flash(:error, msg)
    |> redirect(to: group_path(conn, :edit, group))
  end

  def remind_rest(conn, %{"event_key" => event_key}) do
    event = Network.get_first_node!(:key, event_key)
    group = Network.get_node!(event.meta.parent_id)
    if (!group.email) do
      missing_group_email(conn, group)
    else
      attendees = Network.related_subjects(event, "at")
      rest = Network.node_members(group) -- attendees
      Logger.warn("remind_rest.rest\n"<>inspect(rest))
      url = @server <> rsvp_path(conn, :by_event, event_key)
      emails = rest
      |> Enum.map(fn m -> "#{m.name} <#{m.email}>" end)
      |> Enum.join(",")
      message = "Subject: #{event.name}\nBody: #{url}\n To: #{emails}"
      conn
      |> put_flash(:info, "Reminders\n#{message}")
      |> redirect(to: event_path(conn, :show, event))
    end
  end

  defp email_member(message, member, url) do
    try do
      Sendmail.to_member(message, member, url) |> Mailer.deliver_now()
    rescue
      e in Bamboo.ApiError -> Logger.error("failed.send_email.member\n#{inspect(member)}\n#{inspect(e)}")
    end
  end

  def send_email(conn, %{"event_key" => event_key}) do
    event = Network.get_first_node!(:key, event_key)
    group = Network.get_node!(event.meta.parent_id)
    if (!group.email) do
      missing_group_email(conn, group)
    else
      message = Sendmail.event_message(group, event)
      for member <- Network.node_members(group) do
        if (member.email =~ "@") do
          url = @server <> rsvp_path(conn, :by_email, event_key, member.email)
          email_member(message, member, url)
        end
      end
      conn
      |> put_flash(:info, "Succeess: emails sent")
      |> redirect(to: event_path(conn, :show, event))
    end
  end
end
