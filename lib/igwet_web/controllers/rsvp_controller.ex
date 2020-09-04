# Sample email: http://bin.mailgun.net/b1748eea#7jmd

defmodule IgwetWeb.RsvpController do
  use IgwetWeb, :controller
  require Logger
  alias Igwet.Network
  alias Igwet.Network.Node
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
    current = Network.count_attendance(event)
    changeset = Network.change_node(%Node{})

    conn
    |> assign(:current_user, nil)
    |> assign(:group, Network.get_node!(event.meta.parent_id))
    |> assign(:houses, Network.related_subjects(event, "at"))
    |> render("event.html", event: event, current: current, changeset: changeset)
  end

  def add_email(conn, %{"event_key" => event_key, "node" => params}) do
    path = rsvp_path(conn, :by_email, event_key, params["email"])
    redirect conn, to: path
  end

  def by_email(conn, %{"event_key" => event_key, "email" => email}) do
    event = Network.get_first_node!(:key, event_key)
    group = Network.get_node!(event.meta.parent_id)
    node = Network.get_member_for_email(email, group)
    current = Network.count_attendance(event)
    open = event.size - current
    if (open < 1) do
      msg = "Sorry: #{event.name} is already at its full capacity of #{event.size}"
      conn
      |> put_flash(:notice, msg)
      |> redirect(to: rsvp_path(conn, :by_event, %{"event_key" => event_key}))
    else
      conn
      |> assign(:current_user, nil)
      |> assign(:group, group)
      |> assign(:node, node)
      |> render("email.html", event: event, current: current, open: min(open, @max_rsvp))
    end
end

  def by_count(conn, %{"event_key" => event_key, "email" => email, "count" => count}) do
    event = Network.get_first_node!(:key, event_key)
    group = Network.get_node!(event.meta.parent_id)
    node = Network.get_member_for_email(email, group)
    msg = case Network.attend!(String.to_integer(count), node, group) do
      {:ok, total} ->
        "Added #{count} for #{node.name} <#{node.email}>. Now #{total} attending #{event.name}"
      {:error, current} ->
        "Error #{count}: already #{current} of total capacity #{event.size} attending #{event.name}"
    end
    conn
    |> put_flash(:error, msg)
    |> redirect(to: rsvp_path(conn, :by_event, event_key))
  end

end
