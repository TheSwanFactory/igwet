defmodule Igwet.Network.SMS do
  @moduledoc """
  Wrappers and helpers for sending and receiving SMS messages
  See: https://www.twilio.com/docs/sms/twiml
  """

  # require IEx; #IEx.pry

  require Logger
  alias Igwet.Network
#  import ExTwilio.Api

  @body "Body"
  @from "From"
  @to "To"
  @from_city "FromCity"
  @to_city "ToCity"
  @n_media "NumMedia"
  @msg_id "MessageSid"
  @sms_id "SmsSid"
  @acct_id "AccountSid"
  @msg_svc_id "MessagingServiceSid"

  @doc """
  Sample message params
  {
      "sid": "SMxxx",
      "date_created": "Thu, 13 Aug 2020 02:58:31 +0000",
      "date_updated": "Thu, 13 Aug 2020 02:58:31 +0000",
      "date_sent": null,
      "account_sid": "ACxxxx",
      "to": "+14085551212",
      "from": "+12105551212",
      "messaging_service_sid": "MGxxx",
      "body": "This is my fight song",
      "status": "accepted",
      "num_segments": "0",
      "num_media": "0",
      "direction": "outbound-api",
      "api_version": "2010-04-01",
      "price": null,
      "price_unit": null,
      "error_code": null,
      "error_message": null,
      "uri": "/2010-04-01/Accounts/ACxxxx/Messages/SMxxx.json",
      "subresource_uris": {
          "media": "/2010-04-01/Accounts/ACxxxx/Messages/SMxxx/Media.json"
      }
  }

  ## Examples
      iex> alias Igwet.Network.SMS
      iex> params = SMS.test_params("test_params")
      iex> params["To"]
      "+13105555555"
      iex> node = params[:sender]
      iex> node.name
      "from"
      iex> node.phone
      params["From"]
  """

  def test_params(prefix) do
    params = %{
      @from => "+12125551234",
      @to => "+13105555555",
      @body => "Hello, Twirled!",
      @msg_svc_id => "msg-id",
      @acct_id => "acct_id",
      @sms_id => "sms_id",
      @msg_id => "123344",
      @n_media => 0,
      'ProvideFeedback' => true,
      'ForceDelivery' => true,
      'ContentRetention' => true,
      'AddressRetention' => true,
      'SmartEncoded' => true,
      "Debug" => true
    }
    {:ok, sender} = Network.create_node %{name: "from", phone: params["From"], key: prefix <> "+from"}
    {:ok, receiver} = Network.create_node %{name: "to", phone: params["To"], key: prefix <> "+to"}
    Network.set_node_in_group(sender, receiver)
    Map.merge(params, %{
      prefix: prefix,
      sender: sender,
      receiver: receiver,
      initials: Enum.map([sender, receiver], & Network.get_initials(&1))
    })
  end

  def phone2member(params, phone) do
    name = "member:" <> phone
    {:ok, member} = Network.create_node %{name: name, phone: phone, key: params[:prefix] <> "+" <> name}
    Network.set_node_in_group(member, params[:receiver])
    params
  end

  # Should probably do this with function clauses
  defp ensure_parameter!(params, key) do
    if !Map.has_key?(params, key), do: raise("No parameter named '#{key}'")
  end

  @doc """
  Filter Headers
  Remove keys we explicitly set elsewhere
  Create @received_list and add self

  ## Examples
      iex> alias Igwet.Network.SMS
      iex> SMS.test_params("relay_sms")
      ...> |> SMS.phone2member("+13125551212")
      ...> |> SMS.phone2member("+18155551212")
      ...> |> SMS.relay_sms()
      ...> |> Enum.sort()
      [%{body: "Hello, Twirled!", debug: true, from: "+13105555555", to: "+13125551212"}, %{body: "Hello, Twirled!", debug: true, from: "+13105555555", to: "+18155551212"}]
  """

  def relay_sms(params) do
    params
    |> to_nodes()
    |> add_recipients()
    |> send_messages()
  end

  @doc """
  Convert webhook parameters to nodes

  ## Examples
      iex> alias Igwet.Network.SMS
      iex> params = SMS.test_params("to_nodes")
      iex> %{sender: sender, receiver: _receiver, text: _text} = SMS.to_nodes params
      iex> sender.name
      "from"
      iex> sender.phone
      params["From"]
  """

  def to_nodes(params) do
    ensure_parameter!(params, @from)
    ensure_parameter!(params, @to)
    ensure_parameter!(params, @body)
    ensure_parameter!(params, @msg_id)

    #Logger.warn("** to_nodes.params[@from]: " <> params[@from])
    sender = Network.get_contact_for_phone(params[@from], params[@from_city])
    receiver = Network.get_contact_for_phone(params[@to], params[@to_city])
    text = params[@body] #Network.get_initials(sender) <> ": " <>
    msg_key = "chat+" <> sender.key <> "+" <> params[@msg_id]
    {:ok, datetime} = DateTime.now(sender.timezone)
    {:ok, message} = Network.create_node %{
      about: inspect(params),
      date: datetime,
      key: msg_key,
      name: text,
      size: String.length(text),
      type: "chat"
    }
    #Network.set_node_in_group(message, receiver)
    Network.make_edge(message, "from", sender)

    Map.merge(params, %{
      message: message,
      receiver: receiver,
      sender: sender,
      text: text,
    })
  end

  @doc """
  Lookup recipients in receiver
  Remove the sender

  ## Examples
      iex> alias Igwet.Network.SMS
      iex> params = SMS.test_params("add_recipients")
      ...>          |> SMS.phone2member("+13125551212")
      ...>          |> SMS.phone2member("+18155551212")
      ...>          |> SMS.to_nodes()
      ...>          |> SMS.add_recipients
      iex> params[:phones] |> Enum.sort()
      ["+13125551212","+18155551212"]
      iex> list = params[:recipients]
      iex> length(list)
      2
  """

  def add_recipients(params) do
    sender = params[:sender]
    recipients = params[:receiver]
                 |> Network.node_members()
                 |> List.delete(sender)
    edges = Enum.map(recipients, & Network.make_edge(params[:message], "to", &1))
    Map.merge(params, %{
      recipients: recipients,
      phones: Enum.map(recipients, & &1.phone),
      edges: edges
    })
  end

  @doc """
  Create event message to group phone number
  iex> alias Igwet.Network.SMS
  iex> msg = SMS.group_event_message("+5551212", "title", "url")
  iex> msg.to
  "+5551212"
  iex> msg.body
  "New URL for title: url"
  """

  def group_event_message(group_phone, event_title, event_url) do
    message = "New URL for #{event_title}: #{event_url}"
    host = Network.get_first_node!(:name, "IGWET")
    %{
      to: group_phone,
      from: host.phone,
      body: message,
      debug: false,
    }
  end

  @doc """
  Send message to recipients
  If DEBUG, just log.
  iex> alias Igwet.Network.SMS
  iex> SMS.test_params("add_recipients")
  ...> |> Map.merge(%{phones: ["+13125551212","+18155551212"], text: "Hello, Twirled!"})
  ...> |> SMS.send_messages()
  [%{body: "Hello, Twirled!", debug: true, from: "+13105555555", to: "+13125551212"}, %{body: "Hello, Twirled!", debug: true, from: "+13105555555", to: "+18155551212"}]
  ## Examples
  """

  def send_messages(params) do
    params[:phones]
    |> Enum.map(& %{to: &1, from: params[:receiver].phone, body: params[:text], debug: params["Debug"]})
    |> Enum.map(& send_message(&1))
  end

  def send_message(dict) do
    Logger.debug("send_message: " <> inspect(dict))
    if (!dict.debug) do
      ExTwilio.Message.create dict
    end
    dict
  end

end
