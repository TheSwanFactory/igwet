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

  def downcase_map(params) do
    for {key, val} <- params, into: %{}, do: {String.to_atom(String.downcase(key)), val}
  end


    @doc """
    Sample message params

    ## Examples
        iex> alias Igwet.Network.Message
        iex> params = Message.downcase_emails %{recipient: "M@igwet.com", sender: "Bob@IGWET.COM"}
        iex> params.recipient
        "m@igwet.com"
    """

  def downcase_emails(params) do
    %{params | sender: String.downcase(params.sender), recipient: String.downcase(params.recipient)}
  end

  @doc """
  Sample message params

  ## Examples
      iex> alias Igwet.Network.Message
      iex> params = Message.test_webhook
      iex> params.sender
      "chandler@mg.igwet.com"
      iex> params.recipient
      "monica@mg.igwet.com"
  """

  def test_webhook() do
    %{
      "recipient"	=> "Monica@mg.igwet.com",
      "sender"	=> "chandler@mg.igwet.com",
      "subject"	=> "Re: Sample POST request",
      "from"	=>"Bob <bob@mg.igwet.com>",
      "Message-Id" => "<517ACC75.5010709@mg.igwet.com>",
      "Date"	=> "Fri, 26 Apr 2013 11:50:29 -0700",
      "To"	=> "Alice <alice@mg.igwet.com>",
      "Subject"	=> "Re: Sample POST request",
      "Sender"	=> "bob@mg.igwet.com",
      "message-headers"	=> [["Received", "by luna.mailgun.net with SMTP mgrt 8788212249833; Fri, 26 Apr 2013 18:50:30 +0000"], ["Received", "from [10.20.76.69] (Unknown [50.56.129.169]) by mxa.mailgun.org with ESMTP id 517acc75.4b341f0-worker2; Fri, 26 Apr 2013 18:50:29 -0000 (UTC)"], ["Message-Id", "<517ACC75.5010709@mg.igwet.com>"], ["Date", "Fri, 26 Apr 2013 11:50:29 -0700"], ["From", "Bob <bob@mg.igwet.com>"], ["User-Agent", "Mozilla/5.0 (X11; Linux x86_64; rv:17.0) Gecko/20130308 Thunderbird/17.0.4"], ["Mime-Version", "1.0"], ["To", "Alice <alice@mg.igwet.com>"], ["Subject", "Re: Sample POST request"], ["References", "<517AC78B.5060404@mg.igwet.com>"], ["In-Reply-To", "<517AC78B.5060404@mg.igwet.com>"], ["Content-Type", "multipart/mixed; boundary=\"------------020601070403020003080006\""], ["Sender", "bob@mg.igwet.com"]],
      "timestamp" => "1521723603",
      "body-plain" => "Hi Alice, This is Bob. I also attached a file. Thanks, Bob On 04/26/2013 11:29 AM, Alice wrote: > Hi Bob, > > This is Alice. How are you doing? > > Thanks, > Alice",
      "body-html" =>  "<html> <body ><b> I also attached a file.</b> <br> </div> <blockquote>Hi Bob, <br> <br> This is Alice. How are you doing? <br> <br> Thanks, <br> Alice <br> </blockquote> <br> </body> </html>",
      "stripped-html" =>  "<html> <body ><b> I also attached a file.</b> <br> </div> </body> </html>",
      "stripped-text" => "Hi Alice, This is Bob. I also attached a file.",
      "stripped-signature"	=> "Thanks, Bob",
    }
    |> downcase_map
    |> downcase_emails

  end

  @doc """
  Convert Mailgun web params into a Bamboo email

  ## Examples
      iex> alias Igwet.Network.Message
      iex> params = Message.test_webhook |> Message.params_to_email
      iex> params.from
      "Bob <bob@mg.igwet.com>"

  """

  def params_to_email(params) do
    new_email(
      to: params.to,
      cc: params[:cc],
      from: params.from,
      subject: params.subject,
      text_body: params[:"body-plain"],
      html_body: params[:"body-html"]
    )
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
