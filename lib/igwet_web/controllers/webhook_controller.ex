# Sample email: http://bin.mailgun.net/b1748eea#7jmd
require Protocol
Protocol.derive(Jason.Encoder, RuntimeError)
Protocol.derive(Jason.Encoder, Ecto.NoResultsError)

defmodule IgwetWeb.WebhookController do
  use IgwetWeb, :controller
  require Logger

  alias Igwet.Network.Sendmail
  alias Igwet.Network.SMS
  alias Igwet.Admin.Mailer

  defp peer(conn) do
    %{address: host, port: port} = Plug.Conn.get_peer_data(conn)
    "#{Tuple.to_list(host) |> Enum.join(".")}:#{port}"
  end

  def receive_sms(conn, params) do
    Logger.debug("** params: " <> inspect(params))
    try do
      params
      |> SMS.relay_sms()

      now = DateTime.to_string(DateTime.utc_now())
      conn
      |> put_status(:created)
      |> json(%{created_at: now})
    rescue
      e ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: e})
    end
  end

  def forward_email(conn, params) do
    now = DateTime.to_string(DateTime.utc_now())
    received = "from #{peer(conn)} by #{conn.host}; #{now}"

    try do
      params
      |> Sendmail.normalize_params()
      |> Sendmail.add_received_header(received)
      |> Sendmail.mask_sender()
      |> Sendmail.expand_recipients()
      |> Sendmail.save_as_node()
      |> Sendmail.params_to_email_list()
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
