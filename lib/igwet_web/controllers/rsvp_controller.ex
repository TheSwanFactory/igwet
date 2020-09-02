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

  def by_event(conn, %{"event_key" => key}) do
    event = Network.get_first_node!(:key, key)
    houses = Network.related_subjects(event, "at")
    conn
    |> assign(:current_user, nil)
    |> render("show.html", event: event, houses: houses)
  end

end
