defmodule Igwet.Network.Message do
  @moduledoc """
  Wrappers and helpers for sending and receiving messages
  """

  # require IEx; #IEx.pry
  alias Igwet.Network

  import Bamboo.Email

  defimpl Bamboo.Formatter, for: Igwet.Network.Node do
    # Used by `to`, `bcc`, `cc` and `from`
    def format_email_address(node, _opts) do
      {node.name, node.email}
    end
  end
  @doc """
  Replace Recipient and Sender with IGWET aliases

  ## Examples
      iex> params = %{"Sender" => "test@example.com", "Recipient" => "info@theswanfactory.com"}
      iex> alias Igwet.Network.Message
      iex> {:ok, aliased} = Message.alias_addresses(params)
      iex> aliased["Recipient"]
      "com.igwet.operator"
  """

  def alias_addresses(params) do
  end


  @doc """
  Create a node of type Message from the aliased headers

  ## Examples
      iex> params = %{"Sender" => "com.igwet.operator", "Recipient" => "com.igwet.operator"}
      iex> alias Igwet.Network.Message
      iex> node = Message.create_node_from_email(params)
      %Igwet.Network.Node{}
  """

  def create_node_from_email(aliased) do
  end


  @doc """
  Create Bamboo email from Mailgun Headers

  ## Examples
      iex> params = %{"Sender" => "com.igwet.operator", "Recipient" => "com.igwet.operator"}
      iex> alias Igwet.Network.Message
      iex> email = Message.email_from_headers(params)
      %Bamboo.Email{}
  """

  def email_from_headers(aliased) do
  end


  @doc """
  Verify Mailgun Configuration

  ## Examples
      iex> node = %Igwet.Network.Node{name: "Test", email: "test@example.com"}
      iex> alias Igwet.Network.Message
      iex> result = Message.test_email(node) |> Igwet.Admin.Mailer.deliver_now
      iex> result.headers["Sender"]
      "list@igwet.com"
      iex> result.text_body
      "welcome"
      iex> result.to
      [{node.name, node.email}]

  """

  def test_email(node) do
    user = Igwet.Network.get_first_node_named!("operator")

    new_email()
    |> to(node)
    |> from(user)
    |> subject("Igwet.Admin.Mailer test")
    |> html_body("<strong>Welcome</strong>")
    |> text_body("welcome")
    |> put_header("Sender", "list@igwet.com")
    |> put_header("List-Archive", "<https://www.igwet.com/network/node/operator")
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
