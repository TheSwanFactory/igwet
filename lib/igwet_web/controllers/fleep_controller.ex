# Sample email: http://bin.mailgun.net/b1748eea#7jmd

defmodule IgwetWeb.FleepController do
  use IgwetWeb, :controller
  require Logger
  alias Igwet.Network
  alias Igwet.Network.Node
  def index(conn, _params) do
    nodes = Network.get_nodes_of_type("fleep")
    conn
    |> assign(:current_user, nil)
    |> render("index.html", nodes: nodes)
  end

end
