# Sample email: http://bin.mailgun.net/b1748eea#7jmd

defmodule IgwetWeb.WebhookController do
  use IgwetWeb, :controller

  alias Igwet.Network.Message

  def forward_email(conn, params) do
    params
    |> Igwet.Admin.Mailer.deliver_now()

    conn
  end
end
