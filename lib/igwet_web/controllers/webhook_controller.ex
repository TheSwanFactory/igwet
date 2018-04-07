# Sample email: http://bin.mailgun.net/b1748eea#7jmd

defmodule IgwetWeb.WebhookController do
  use IgwetWeb, :controller
  require Logger

  alias Igwet.Network.Message
  alias Igwet.Admin.Mailer

  defp peer(conn) do
    {host, port} = conn.peer
    "#{Tuple.to_list(host) |> Enum.join(".")}:#{port}"
  end

  def forward_email(conn, params) do
    now = DateTime.to_string(DateTime.utc_now())
    received = "from #{peer(conn)} by #{conn.host}; #{now}"

    try do
      params
      |> Message.normalize_params()
      |> Message.add_received_header(received)
      |> Message.mask_sender()
      |> Message.expand_recipients()
      |> Message.save_as_node()
      |> Message.params_to_email_list()
      |> Enum.map(&Mailer.deliver_now/1)

      conn
      |> put_status(:created)
      |> json(%{created_at: params["timestamp"]})
    rescue
      e ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: e})
    end
  end
end
