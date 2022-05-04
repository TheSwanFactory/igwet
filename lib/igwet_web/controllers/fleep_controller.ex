# Sample email: http://bin.mailgun.net/b1748eea#7jmd

defmodule IgwetWeb.FleepController do
  use IgwetWeb, :controller
  require Logger
  alias Igwet.Network
  alias Igwet.Network.Node
  alias Igwet.Network.SMS
  alias Igwet.Scheduler
  alias Igwet.Scheduler.Helper
  @max_rsvp 6
  @server "https://www.igwet.com"

  def index(conn, _params) do
    fleep = Network.get_predicate("fleep")
    nodes = Network.related_subjects(fleep, "type")
    conn
    |> assign(:current_user, nil)
    |> render("index.html", fleeps: nodes)
  end

end
