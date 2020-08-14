defmodule Igwet.Network.SMS do
  @moduledoc """
  Wrappers and helpers for sending and receiving SMS messages
  See: https://www.twilio.com/docs/sms/twiml
  """

  # require IEx; #IEx.pry

  require Logger
  alias Igwet.Network
#  import ExTwilio.Api

  @from "from"
  @to "to"
  @body "body"
  @n_media "NumMedia"
  @msg_id "MessageSid"
  @sms_id "SmsSid"
  @acct_id "AccountSid"
  @msg_svc_id "MessagingServiceSid"
  @node "node"


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
      iex> params["to"]
      "+13105555555"
      iex> node = params[:sender]
      iex> node.name
      "from"
      iex> node.phone
      params["from"]
  """

  def test_params(prefix) do
    params = %{
      @from => "+12125551234",
      @to => "+13105555555",
      @body => "Hello from my Twilio line!",
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
    }
    {:ok, sender} = Igwet.Network.create_node %{name: "from", phone: params["from"], key: prefix <> "from"}
    {:ok, receiver} = Igwet.Network.create_node %{name: "to", phone: params["to"], key: prefix <> "to"}
    Map.merge(params, %{
      sender: sender,
      receiver: receiver,
    })
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
      iex> params = SMS.test_params("relay_sms")
      iex> _list = SMS.relay_sms(params)
  """

  def relay_sms(params) do
    params
    |> to_nodes()
    #|> expand_recipients()
    #|> save_as_node()
    #|> params_to_sms_list()
    #|> Enum.map(&deliver_now/1)
  end

  @doc """
  Convert webhook parameters to nodes

  ## Examples
      iex> alias Igwet.Network.SMS
      iex> params = SMS.test_params("to_nodes")
      iex> %{sender: sender, receiver: receiver, message: message} = SMS.to_nodes params
      iex> sender.name
      "from"
      iex> sender.phone
      params["from"]
      iex> [head | _tail] = String.split(message, ":")
      iex> head
      "f"
  """

  def to_nodes(params) do
    ensure_parameter!(params, @from)
    ensure_parameter!(params, @to)
    ensure_parameter!(params, @body)
    %{@from => from, @to => to, @body => body} = params
    sender = Network.get_first_node!(:phone, from)
    receiver = Network.get_first_node!(:phone, to)
    message = Network.get_initials(sender) <> ": " <> body
    Map.merge(params, %{
      sender: sender,
      receiver: receiver,
      message: message,
    })
  end

  @doc """
  Lookup recipients in receiver
  Remove the sender

  ## Examples
      iex> alias Igwet.Network.SMS
      iex> params = SMS.test_params("expand_recipients")
      iex> list = SMS.expand_recipients(params)["recipients"]
      iex> length(list)
      2
      "+13105555555"
  """

  def expand_recipients(params) do
    [params]
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
      iex> alias Igwet.Network.SMS
      iex> params = SMS.save_as_node SMS.test_params("save_as_node")
      iex> %{key: key} = params["node"]
      iex> key
      "com.igwet+admin+operator"

  """

  def save_as_node(params) do
    node = Network.get_first_node!(:name, "operator")

    params
    |> Map.put(@node, node)
  end
end
