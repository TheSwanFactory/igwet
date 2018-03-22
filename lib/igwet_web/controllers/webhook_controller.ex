# Sample email: http://bin.mailgun.net/b1748eea#7jmd

defmodule IgwetWeb.WebhookController do
  use IgwetWeb, :controller

  alias Igwet.Network

  def receive_email(_conn, params) do
    message = Network.create_message_from_email(params)
    Network.forward_message_securely(message, params)
  end
end
