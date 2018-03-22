# Sample email: http://bin.mailgun.net/b1748eea#7jmd

defmodule IgwetWeb.WebhookController do
  use IgwetWeb, :controller

  alias Igwet.Network.Message

  def forward_email(conn, params) do
    aliased = Message.alias_addresses(params)
    node = Message.create_node_from_email(aliased)
    email = Message.email_from_headers(aliased)
    email |> Igwet.Admin.Mailer.deliver_now
    conn
  end
end
