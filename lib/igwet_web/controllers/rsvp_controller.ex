# Sample email: http://bin.mailgun.net/b1748eea#7jmd

defmodule IgwetWeb.RsvpController do
  use IgwetWeb, :controller
  require Logger
  alias Igwet.Network

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
    conn
    |> assign(:current_user, nil)
    |> assign(:group, group)
    |> assign(:node, node)
    |> render("email.html", event: event)
  end

  def by_count(conn, %{"event_key" => event_key, "email" => email, "count" => count}) do
    event = Network.get_first_node!(:key, event_key)
    group = Network.get_node!(event.meta.parent_id)
    node = Network.get_member_for_email(email, group)
    Network.make_attendance(count, node, group)
    msg = "Set #{count} for #{node.name} <#{node.email}> attending #{group.name}"
    conn
    |> put_flash(:info, msg)
    |> redirect(to: rsvp_path(conn, :by_event, %{"event_key" => event_key}))
  end

end
