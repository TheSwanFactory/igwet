# Sample email: http://bin.mailgun.net/b1748eea#7jmd

defmodule IgwetWeb.FleepController do
  use IgwetWeb, :controller
  require Logger
  alias Igwet.Network

  def index(conn, _params) do
    nodes = Network.get_nodes_of_type("fleep.conv")
    conn
    |> assign(:current_user, nil)
    |> render("index.html", nodes: nodes)
  end

  def edit(conn, %{"id" => id}) do
    conv = Network.get_node!(id)
    changeset = Network.change_node(conv)
    render(conn, "edit.html", conv: conv, changeset: changeset)
  end

  def show(conn, %{"id" => id}) do
    conv = Network.get_node!(id)
    messages = Network.node_members(conv)
    conn
    |> assign(:messages, messages)
    |> assign(:current_user, nil)
    |> render("show.html", conv: conv)
  end

end

#def conversation_sync(self,
# conversation_id, from_message_nr = None, mk_direction = 'forward'):
#    return self._webapi_call('api/conversation/sync', conversation_id,
