defmodule Igwet.Network.Message do
  @moduledoc """
  Wrappers and helpers for sending and receiving messages
  """

  # require IEx; #IEx.pry
  alias Igwet.Network

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
      nil -> Enum.map(Network.node_members(node), fn x -> x.email end)
      _ -> [node.email]
    end
  end

end
