defmodule Igwet.Admin.Mailer do
  @moduledoc """
  Use Mailgun to generate email messages
  """
  use Bamboo.Mailer, otp_app: :igwet
end
