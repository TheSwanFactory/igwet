defmodule Igwet.Network.Factory do
  @moduledoc """
  Helper methods for creating Nodes and Edges using appropriate keys
  """

  import Ecto.Query, warn: false
  alias Igwet.Repo, warn: false
  alias Igwet.Network, warn: false
  alias Igwet.Network.Node, warn: false
  alias Igwet.Network.Edge, warn: false

  @doc """
  Converts an arbitrary string into a suitable key

  ## Examples
      iex> alias Igwet.Network.Factory
      iex> Factory.key_from_string("Hello, World! ")
      "hello_world"

  """

  def key_from_string(string) do
    string
    |> String.trim
    |> String.downcase
    |> String.replace(~r/\W+/, "_")
    |> String.trim("_")
  end

  @doc """
  Creates a node of a given type, generating key if necessary

  ## Examples

      iex> alias Igwet.Network.Factory
      iex> Factory.create_typed_node!(%{key: "none"})
      {:error,  "missing type"}


  """
  def create_typed_node!(attrs \\ %{}) do
    if !Map.has_key?(attrs, :type) do
      {:error,  "missing type"}
    end
  end

end
