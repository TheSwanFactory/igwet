defmodule Igwet.Network.SMS do
  @moduledoc """
  Wrappers and helpers for sending and receiving SMS messages
  See: https://www.twilio.com/docs/sms/twiml
  """

  # require IEx; #IEx.pry

  require Logger
  alias Igwet.Network
  import ExTwilio.Api

  @from "from"
  @to "to"
  @body "body"
  @n_media "NumMedia"
  @msg_id "MessageSid"
  @sms_id "SmsSid"
  @acct_id "AccountSid"
  @msg_svc_id "MessagingServiceSid"
  @node "node"
  @recipient "recipient"
  @sender "sender"

  # Should probably do this with function clauses
  defp ensure_parameter!(params, key) do
    if !Map.has_key?(params, key), do: raise("No parameter named '#{key}'")
  end

  @doc """
  Filter Headers
  Remove keys we explicitly set elsewhere
  Create @received_list and add self

  ## Examples
      iex> alias Igwet.Network.Sendmail
      iex> params = Sendmail.test_params() |> Sendmail.downcase_map()
      iex> result = Sendmail.filter_headers params
      iex> headers = result["message-headers"]
      iex> headers[:from]
      nil
      iex> list = Keyword.get_values(headers, :received)
      iex> length(list)
      2
  """

  def relay_sms(params) do
    params
    |> expand_recipients()
    |> save_as_node()
    |> params_to_sms_list()
    |> Enum.map(&deliver_now/1)
  end

  @doc """
  Convert webhook parameters to nodes

  ## Examples
      iex> alias Igwet.Network.Sendmail
      iex> params = Sendmail.normalize_params(Sendmail.test_params())
      iex> params["recipient"]
      "com.igwet+admin@mg.igwet.com"
  """

  def to_nodes(params) do
    {from, to, body} = params
    sender = Network.get_first_node!(:phone, from)
    receiver = Network.get_first_node!(:phone, to)
    message = Network.get_initials(sender) <> ": " <> body
    %{sender, receiver, message, params}
  end

  @doc """
  Add local Received header

  ## Examples
      iex> alias Igwet.Network.Sendmail
      iex> normal = Sendmail.normalize_params(Sendmail.test_params())
      iex> params = Sendmail.add_received_header(normal, "here")
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
      iex> alias Igwet.Network.Sendmail
      iex> source = %{"sender" => "ernest.prabhakar@gmail.com", "from" => "nobody", "message-headers" => []}
      iex> params = Sendmail.mask_sender source
      iex> params["sender"]
      "com.igwet+admin+operator@example.com"
      iex> params["from"]
      {"operator", "com.igwet+admin+operator@example.com"}
  """

  def mask_sender(params) do
    ensure_parameter!(params, @sender)
    ensure_parameter!(params, @from)
    sender_email = params[@sender]

    try do
      node = Network.get_first_node!(:email, sender_email)
      keyed_email = Mailer.keyed_email(node)

      updates = %{
        @sender => keyed_email,
        @from => {node.name, keyed_email},
        @headers => [sender: keyed_email] ++ params[@headers]
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
      iex> alias Igwet.Network.Sendmail
      iex> params = Sendmail.expand_recipients Sendmail.test_params()
      iex> [head | tail] = params["recipient_list"]
      iex> length(tail)
      0
      iex> head.name
      "operator"
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
      iex> alias Igwet.Network.Sendmail
      iex> [%{email: email}] = Network.get_first_node!(:name, "operator") |> Sendmail.nodes_with_emails
      iex> email
      "ernest.prabhakar@gmail.com"
      iex> list = Network.get_first_node!(:name, "admin") |> Sendmail.nodes_with_emails
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
  Return a list of nodes (or their members) containing phone numbers
  """
  def nodes_with_phones(node) do
    case node.phone do
      nil ->
        Network.node_members(node)
        |> Enum.map(&nodes_with_phones/1)
        |> List.flatten()

      _ ->
        [node]
    end
  end


  @doc """
  Store the message as a node with links to the From and To

  ## Examples
      iex> alias Igwet.Network.Sendmail
      iex> params = Sendmail.save_as_node Sendmail.test_params()
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
      iex> alias Igwet.Network.Sendmail
      iex> email = Sendmail.test_params() |> Sendmail.params_to_email()
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
    |> add_headers(params[@headers])
  end

  defp add_headers(email, headers) do
    # Add received headers
    Enum.reduce(headers, email, &add_header/2)
  end

  defp add_header(header, email) when is_list(header) do
    [key, value] = header
    put_header(email, key, value)
  end

  defp add_header(header, email) when is_tuple(header) do
    {key, value} = header
    put_header(email, as_string(key), value)
  end

  defp as_string(key) when is_atom(key), do: Atom.to_string(key)

  @doc """
  Use recipient_list to generate a list of emails

  ## Examples
      iex> alias Igwet.Network.Sendmail
      iex> params = Sendmail.test_params()
      iex> new_params = Map.put_new(params, "recipient_list", [params["recipient"]])
      iex> emails = Sendmail.params_to_email_list(new_params)
      iex> length(emails)
      1

  """

  def params_to_email_list(params) do
    ensure_parameter!(params, @recipient_list)

    for recipient <- params[@recipient_list] do
      params
      |> Map.replace!(@recipient, recipient)
      |> Map.replace!(@to, recipient)
      |> params_to_email()
    end
  end

  @doc """
  Verify Mailgun Configuration

  ## Examples
      iex> node = %Igwet.Network.Node{name: "Test", email: "test@example.com"}
      iex> alias Igwet.Network.Sendmail
      iex> result = Sendmail.test_email(node) |> Igwet.Admin.Mailer.deliver_now
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
      iex> alias Igwet.Network.Sendmail
      iex> params = Sendmail.test_params
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
      @headers => [
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
