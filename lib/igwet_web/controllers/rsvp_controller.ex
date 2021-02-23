# Sample email: http://bin.mailgun.net/b1748eea#7jmd

defmodule IgwetWeb.RsvpController do
  use IgwetWeb, :controller
  require Logger
  alias Igwet.Network
  alias Igwet.Network.Node
  alias Igwet.Network.Sendmail
  alias Igwet.Network.SMS
  alias Igwet.Admin.Mailer
  alias Igwet.Scheduler
  @max_rsvp 6
  @server "https://www.igwet.com"

  def index(conn, _params) do
    event = Network.get_predicate("event")
    nodes = Network.related_subjects(event, "type")
    conn
    |> assign(:current_user, nil)
    |> render("index.html", events: nodes)
  end

  def to_upcoming(conn, params) do
    event_key = params["event_key"]
    method = if (Map.has_key?(params, "action")) do
      String.to_atom(params["action"])
    else
      :by_event
    end
    Logger.debug("to_upcoming.method: #{method}")
    event = Network.last_event!(event_key)
    upcoming = Network.upcoming_event!(event)
    path = rsvp_path(conn, method, upcoming.key)
    redirect(conn, to: path)
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
      url = @server <> rsvp_path(conn, :by_event, event_key)
      emails = rest
      |> Enum.map(fn m -> "#{m.name} <#{m.email}>" end)
      |> Enum.join(", ")
      message = "To: #{length(rest)} members | Subject: #{event.name}\n | Body: #{url}\n "
      conn
      |> put_flash(:info, message)
      |> assign(:reminders, emails)
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

  defp sms_event_owner(message, event) do
    if (event.phone) do
      %{debug: true, to: event.phone, body: message}
      |> Map.put(:from, System.get_env("PHONE_IGWET"))
      |> SMS.send_message()
    end
  end

  def send_email(conn, %{"event_key" => event_key}) do
    event = Network.get_first_node!(:key, event_key)
    group = Network.get_node!(event.meta.parent_id)
    if (!group.email) do
      missing_group_email(conn, group)
    else
      msg = email_event(event)
      sms_event_owner(msg, event)
      conn
      |> put_flash(:info, "Success: #{msg}")
      |> redirect(to: rsvp_path(conn, :by_event, event.key))
    end
  end

  def email_event(event) do
    group = Network.get_node!(event.meta.parent_id)
    message = Sendmail.event_message(group, event)
    result = for member <- Network.node_members(group) do
      if (member.email && (member.email =~ "@")) do
        # https://www.igwet.com/rsvp/for/us.kingsway.0kss_2021-02-21/ernest%40drernie.com
        email = String.replace(member.email, "@", "%40")
        url = @server <> "/rsvp/for/" <> event.key <> "/" <> email
        email_member(message, member, url)
        member.email
      end
    end
    "#{Enum.count(result)} emails sent\n #{inspect result}"
  end

  def perform_task(conn, %{"event_key" => event_key}) do
    event = Network.get_first_node!(:key, event_key)
    msg = Scheduler.perform_task(event)
    conn
    |> put_flash(:info, "Task Result: #{msg}")
    |> redirect(to: reminder_path(conn, :show, event))
  end

  def test(event) do
    Logger.warn("RSVP.test: #{event.key}")
  end
end
