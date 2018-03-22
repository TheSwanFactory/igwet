# Sample email: http://bin.mailgun.net/b1748eea#7jmd

defmodule IgwetWeb.WebhookController do
  use IgwetWeb, :controller

  alias Igwet.Network.Message

  def forward_email(_conn, params) do
    node = Message.create_node_from_email(params)
    email = Message.alias_email(node, params)
    email |> Igwet.Admin.Mailer.deliver_now
  end
end
