# Sample email: http://bin.mailgun.net/b1748eea#7jmd

defmodule IgwetWeb.RsvpController do
  use IgwetWeb, :controller
  require Logger
  alias Igwet.Network
  @max_rsvp 6

  def index(conn, _params) do
    event = Network.get_first_node!(:name, "event")
    nodes = Network.related_subjects(event, "type")
    conn
    |> assign(:current_user, nil)
    |> render("index.html", events: nodes)
  end

  def by_event(conn, %{"event_key" => event_key}) do
    event = Network.get_first_node!(:key, event_key)
    conn
    |> assign(:current_user, nil)
    |> assign(:group, Network.get_node!(event.meta.parent_id))
    |> assign(:houses, Network.related_subjects(event, "at"))
    |> render("event.html", event: event)
  end

  def by_email(conn, %{"event_key" => event_key, "email" => email}) do
    event = Network.get_first_node!(:key, event_key)
    group = Network.get_node!(event.meta.parent_id)
    node = Network.get_member_for_email(email, group)
    open = event.meta.capacity - event.meta.current
    if (open < 1) do
      msg = "Sorry: #{event.meta.current} of total capacity #{event.meta.capacity} already attending #{event.name}"
      conn
      |> put_flash(:notice, msg)
      |> redirect(to: rsvp_path(conn, :by_event, %{"event_key" => event_key}))
    else
      conn
      |> assign(:current_user, nil)
      |> assign(:group, group)
      |> assign(:node, node)
      |> render("email.html", event: event, open: min(open, @max_rsvp))
    end
end

  def by_count(conn, %{"event_key" => event_key, "email" => email, "count" => count}) do
    event = Network.get_first_node!(:key, event_key)
    group = Network.get_node!(event.meta.parent_id)
    node = Network.get_member_for_email(email, group)
    msg = case Network.attend!(count, node, group) do
      {:ok, total} ->
        "Added #{count} for #{node.name} <#{node.email}>. Now #{total} attending #{event.name}"
      {:error} ->
        "Error: already #{event.meta.current} of total capacity #{event.meta.capacity} attending #{event.name}"
    end
    conn
    |> put_flash(:error, msg)
    |> redirect(to: rsvp_path(conn, :by_event, %{"event_key" => event_key}))
  end

end
