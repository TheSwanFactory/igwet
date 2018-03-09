defmodule Igwet.Network.Message do
  @moduledoc """
  Wrappers and helpers for sending and receiving messages
  """

  # require IEx; #IEx.pry
  alias Igwet.Network

  import Bamboo.Email

  @doc """
  Verify Mailgun Configuration

  ## Examples
      iex> alias Igwet.Network.Message
      iex> Message.test_email() |> Igwet.Admin.Mailer.deliver_now
      %Bamboo.Email{}

  """

  def test_email() do
    new_email()
    |> to("ernest.prabhakar@gmail.com")
    |> from("ernest@drernie.com")
    |> subject("Igwet.Admin.Mailer test")
    |> html_body("<strong>Welcome</strong>")
    |> text_body("welcome")
  end

  @doc """
  Returns a list of email for for members of a given node

  ## Examples
      iex> user = Igwet.Network.get_first_node_named!("operator")
      iex> Igwet.Network.Message.emails_for_node(user)
      ["info@theswanfactory.com"]

      iex> group = Igwet.Network.get_first_node_named!("admin")
      iex> Igwet.Network.Message.emails_for_node(group)
      ["info@theswanfactory.com"]

  """

  def member_emails(node) do
    Enum.map(Network.node_members(node), fn x -> x.email end)
  end

  @doc """
  Returns a list of email addreses for a given node

  ## Examples
      iex> user = Igwet.Network.get_first_node_named!("operator")
      iex> Igwet.Network.Message.emails_for_node(user)
      ["info@theswanfactory.com"]

      iex> group = Igwet.Network.get_first_node_named!("admin")
      iex> Igwet.Network.Message.emails_for_node(group)
      ["info@theswanfactory.com"]

  """

  def emails_for_node(node) do
    case node.email do
      nil -> member_emails(node)
      _ -> [node.email]
    end
  end
end
