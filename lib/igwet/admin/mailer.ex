defmodule Igwet.Admin.Mailer do
  @moduledoc """
  Use Mailgun to generate email messages
  """
  use Bamboo.Mailer, otp_app: :igwet

  @doc """
  Return email address generated from key of node

  ## Examples
      iex> alias Igwet.Admin.Mailer
      iex> Mailer.keyed_email %{key: "test"}
      "test@mg.igwet.com"
  """

  def keyed_email(%{key: key}) do
    domain = Application.get_env(:igwet, Igwet.Admin.Mailer)[:domain]
    "#{key}@#{domain}"
  end

end
