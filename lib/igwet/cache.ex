defmodule Igwet.Cache do

  @doc """
  Create a named ets table

  ## Examples
  iex> alias Igwet.Cache
  iex> Cache.create(:test)
  :test

  """

  def create(name) do
    :ets.new(name, [:set, :protected, :named_table])
  end

  def exists(name) do
    False
  end

  def set(name, key, value) do
    value
  end

  def get(name, key) do
    key
  end
end
