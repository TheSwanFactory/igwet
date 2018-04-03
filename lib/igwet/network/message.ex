defmodule Igwet.Network.Message do
  @moduledoc """
  Wrappers and helpers for sending and receiving messages
  """

  # require IEx; #IEx.pry
  require Logger
  alias Igwet.Network
  alias Igwet.Admin.Mailer

  import Bamboo.Email

  @from "from"
  @headers "message-headers"
  @node "node"
  @recipient "recipient"
  @recipient_list "recipient_list"
  @sender "sender"
  @to "to"

  @replaced_headers [@from, @recipient, @sender, @to]

  defimpl Bamboo.Formatter, for: Igwet.Network.Node do
    # Used by `to`, `bcc`, `cc` and `from`
    def format_email_address(node, _opts) do
      {node.name, node.email}
    end
  end

  # Should probably do this with function clauses
  defp ensure_parameter!(params, key) do
    if !Map.has_key?(params, key), do: raise("No parameter named '#{key}'")
  end

  def downcase_map(params) do
    for {key, val} <- params, into: %{}, do: {String.downcase(key), val}
  end

  @doc """
  Normalize sender and recipient email addresess

  ## Examples
      iex> alias Igwet.Network.Message
      iex> params = Message.downcase_addresses %{"recipient" => "M@igwet.com", "sender" => "Bob@IGWET.COM"}
      iex> params["recipient"]
      "m@igwet.com"
  """

  def downcase_addresses(params) do
    ensure_parameter!(params, @sender)
    ensure_parameter!(params, @recipient)

    %{
      params
      | @sender => String.downcase(params[@sender]),
        @recipient => String.downcase(params[@recipient])
    }
  end

  @doc """
  Filter Headers
  Remove keys we explicitly set elsewhere
  Create @received_list and add self

  ## Examples
      iex> alias Igwet.Network.Message
      iex> params = Message.test_params() |> Message.downcase_map()
      iex> result = Message.filter_headers params
      iex> headers = result["message-headers"]
      iex> headers[:from]
      nil
      iex> list = Keyword.get_values(headers, :received)
      iex> length(list)
      2
  """

  def filter_headers(params) do
    ensure_parameter!(params, @headers)
    rejects = Enum.map(@replaced_headers, &String.to_atom/1)

    headers =
      params[@headers]
      |> Enum.map(&header_as_keyword_list/1)
      |> Enum.reject(fn {k, _} -> Enum.member?(rejects, k) end)

    %{params | @headers => headers}
  end

  defp header_as_keyword_list(header) do
    key = Enum.at(header, 0) |> String.downcase() |> String.to_atom()
    value = Enum.at(header, 1)
    {key, value}
  end

  @doc """
  Normalize webhook parameters

  ## Examples
      iex> alias Igwet.Network.Message
      iex> params = Message.normalize_params(Message.test_params())
      iex> params["recipient"]
      "com.igwet+admin@mg.igwet.com"
  """

  def normalize_params(params) do
    params
    |> downcase_map
    |> downcase_addresses
    |> filter_headers
  end

  @doc """
  Add local Received header

  ## Examples
      iex> alias Igwet.Network.Message
      iex> normal = Message.normalize_params(Message.test_params())
      iex> params = Message.add_received_header(normal, "here")
      iex> [head | _] = params["message-headers"]
      iex> head
      {:received, "here"}
  """

  def add_received_header(params, received) do
    ensure_parameter!(params, @headers)
    headers = [received: received] ++ params[@headers]
    %{params | @headers => headers}
  end

  @doc """
  Replace Sender and From information with a node

  ## Examples
      iex> alias Igwet.Network.Message
      iex> params = Message.mask_sender %{"sender" => "ernest.prabhakar@gmail.com", "from" => ""}
      iex> params["sender"]
      "com.igwet+admin+operator@example.com"
  """

  def mask_sender(params) do
    ensure_parameter!(params, @sender)
    ensure_parameter!(params, @from)
    sender_email = params[@sender]

    try do
      node = Network.get_first_node!(:email, sender_email)

      updates = %{
        @from => node,
        @sender => Mailer.keyed_email(node)
      }

      Map.merge(params, updates)
    rescue
      e ->
        raise "Unrecognized sender `#{sender_email}`}\n#{inspect(e)}"
    end
  end

  @doc """
  Lookup the recipient (raise if does not exist)
  Replace the To field
  Replace the Recipient with a list of emailable_nodes

  ## Examples
      iex> alias Igwet.Network.Message
      iex> params = Message.expand_recipients Message.test_params()
      iex> length(params["recipient_list"])
      1
  """

  def expand_recipients(params) do
    ensure_parameter!(params, @recipient)
    recipient_email = params[@recipient]

    email =
      ~r/\A(?<name>[^@]+)@[a-z\d\-]+(?<domain>\.[a-z]+)*\.[a-z]+\z/iu
      |> Regex.named_captures(recipient_email)

    try do
      Network.get_first_node!(:key, email["name"])
      |> nodes_with_emails
      |> (&Map.put(params, @recipient_list, &1)).()
    rescue
      e ->
        raise "Unrecognized recipient `#{recipient_email}`}\n#{inspect(email)}\n#{inspect(e)}"
    end
  end

  @doc """
  Return a list of nodes (or their members) containing emails

  ## Examples
      iex> alias Igwet.Network
      iex> alias Igwet.Network.Message
      iex> [%{email: email}] = Network.get_first_node!(:name, "operator") |> Message.nodes_with_emails
      iex> email
      "ernest.prabhakar@gmail.com"
      iex> list = Network.get_first_node!(:name, "admin") |> Message.nodes_with_emails
      iex> length(list)
      1


  """

  def nodes_with_emails(node) do
    case node.email do
      nil ->
        Network.node_members(node)
        |> Enum.map(&nodes_with_emails/1)
        |> List.flatten()

      _ ->
        [node]
    end
  end

  @doc """
  Store the message as a node with links to the From and To

  ## Examples
      iex> alias Igwet.Network.Message
      iex> params = Message.save_as_node Message.test_params()
      iex> %{key: key} = params["node"]
      iex> key
      "com.igwet+admin+operator"

  """

  def save_as_node(params) do
    node = Network.get_first_node!(:name, "operator")

    params
    |> Map.put(@node, node)
  end

  @doc """
  Convert Mailgun web params into a Bamboo email

  ## Examples
      iex> alias Igwet.Network.Message
      iex> email = Message.test_params |> Message.params_to_email
      iex> email.from
      "Bob <bob@mg.igwet.com>"

  """

  def params_to_email(params) do
    new_email(
      to: params[@to],
      cc: params["cc"],
      from: params[@from],
      subject: params["subject"],
      text_body: params["body-plain"],
      html_body: params["body-html"]
    )
  end

  @doc """
  Use recipient_list to generate a list of emails

  ## Examples
      iex> alias Igwet.Network.Message
      iex> params = Message.test_params
      iex> emails = Map.put(params, "recipient_list", [params["recipient"]]) |> Message.params_to_email_list
      iex> length(emails)
      1

  """

  def params_to_email_list(params) do
    ensure_parameter!(params, @recipient_list)

    for recipient <- params[@recipient_list] do
      params
      |> Map.replace!(@recipient, recipient)
      |> params_to_email()
    end
  end

  @doc """
  Verify Mailgun Configuration

  ## Examples
      iex> node = %Igwet.Network.Node{name: "Test", email: "test@example.com"}
      iex> alias Igwet.Network.Message
      iex> result = Message.test_email(node) |> Igwet.Admin.Mailer.deliver_now
      iex> result.headers["sender"]
      "list@igwet.com"
      iex> result.text_body
      "welcome"
      iex> result.to
      [{node.name, node.email}]

  """

  def test_email(node) do
    user = Igwet.Network.get_first_node!(:name, "operator")

    new_email()
    |> to(node)
    |> from(user)
    |> subject("Igwet.Admin.Mailer test")
    |> html_body("<strong>Welcome</strong>")
    |> text_body("welcome")
    |> put_header(@sender, "list@igwet.com")
    |> put_header("List-Archive", "<https://www.igwet.com/network/node/operator")
  end

  @doc """
  Sample message params

  ## Examples
      iex> alias Igwet.Network.Message
      iex> params = Message.test_params
      iex> params["recipient"]
      "com.igwet+admin@mg.igwet.com"
  """

  def test_params() do
    %{
      @recipient => "com.igwet+admin@mg.igwet.com",
      @sender => "ernest.prabhakar@gmail.com",
      "subject" => "Re: Sample POST request",
      @from => "Bob <bob@mg.igwet.com>",
      "Message-Id" => "<517ACC75.5010709@mg.igwet.com>",
      "Date" => "Fri, 26 Apr 2013 11:50:29 -0700",
      @to => "Alice <alice@mg.igwet.com>",
      "Subject" => "Re: Sample POST request",
      "Sender" => "bob@mg.igwet.com",
      "message-headers" => [
        [
          "Received",
          "by luna.mailgun.net with SMTP mgrt 8788212249833; Fri, 26 Apr 2013 18:50:30 +0000"
        ],
        [
          "Received",
          "from [10.20.76.69] (Unknown [50.56.129.169]) by mxa.mailgun.org with ESMTP id 517acc75.4b341f0-worker2; Fri, 26 Apr 2013 18:50:29 -0000 (UTC)"
        ],
        ["Message-Id", "<517ACC75.5010709@mg.igwet.com>"],
        ["Date", "Fri, 26 Apr 2013 11:50:29 -0700"],
        [@from, "Bob <bob@mg.igwet.com>"],
        [
          "User-Agent",
          "Mozilla/5.0 (X11; Linux x86_64; rv:17.0) Gecko/20130308 Thunderbird/17.0.4"
        ],
        ["Mime-Version", "1.0"],
        [@to, "Alice <alice@mg.igwet.com>"],
        ["Subject", "Re: Sample POST request"],
        ["References", "<517AC78B.5060404@mg.igwet.com>"],
        ["In-Reply-To", "<517AC78B.5060404@mg.igwet.com>"],
        ["Content-Type", "multipart/mixed"],
        [@sender, "bob@mg.igwet.com"]
      ],
      "timestamp" => "1521723603",
      "body-plain" =>
        "Hi Alice, This is Bob. I also attached a file. Thanks, Bob On 04/26/2013 11:29 AM, Alice wrote: > Hi Bob, > > This is Alice. How are you doing? > > Thanks, > Alice",
      "body-html" =>
        "<html> <body ><b> I also attached a file.</b> <br> </div> <blockquote>Hi Bob, <br> <br> This is Alice. How are you doing? <br> <br> Thanks, <br> Alice <br> </blockquote> <br> </body> </html>",
      "stripped-html" =>
        "<html> <body ><b> I also attached a file.</b> <br> </div> </body> </html>",
      "stripped-text" => "Hi Alice, This is Bob. I also attached a file.",
      "stripped-signature" => "Thanks, Bob"
    }
  end
end
