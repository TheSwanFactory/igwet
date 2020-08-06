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
    #|> params_to_sms_list()
    #|> Enum.map(&deliver_now/1)
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
    ensure_parameter!(params, @from)
    ensure_parameter!(params, @to)
    ensure_parameter!(params, @body)
    {from, to, body} = params
    sender = Network.get_first_node!(:phone, from)
    receiver = Network.get_first_node!(:phone, to)
    message = Network.get_initials(sender) <> ": " <> body
    {sender, receiver, message, params}
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

  def expand_recipients(_params) do
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
  Sample message params

  ## Examples
      iex> alias Igwet.Network.Sendmail
      iex> params = Sendmail.test_params
      iex> params["recipient"]
      "com.igwet+admin@mg.igwet.com"
  """

  def test_params() do
    %{
      @sender => "ernest.prabhakar@gmail.com",
      "subject" => "Re: Sample POST request",
      @from => "Bob <bob@mg.igwet.com>",
      "Message-Id" => "<517ACC75.5010709@mg.igwet.com>",
      "Date" => "Fri, 26 Apr 2013 11:50:29 -0700",
      @to => "Alice <alice@mg.igwet.com>",
      "Subject" => "Re: Sample POST request",
      @msg_svc_id => "msg-id",
      @acct_id => "acct_id",
      @sms_id => "sms_id",
      @msg_id => "123344",
      @n_media => 0,
    }
  end
end
