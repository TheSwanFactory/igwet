# Sample email: http://bin.mailgun.net/b1748eea#7jmd

defmodule IgwetWeb.WebhookController do
  use IgwetWeb, :controller

  alias Igwet.Network.Message

  def forward_email(conn, params) do
    try do
      params
      |> Message.normalize_params()
      |> Message.mask_sender()
      |> Message.params_to_email()
      |> Igwet.Admin.Mailer.deliver_now()

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
