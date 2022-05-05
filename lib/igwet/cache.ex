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

  @doc """
  Check if table already exists

  ## Examples
  iex> alias Igwet.Cache
  iex> Cache.exists(:test)
  false
  iex> Cache.create(:test)
  iex> Cache.exists(:test)
  true
  """
  def exists(name) do
    :ets.whereis(name) != :undefined
  end

  @doc """
  Ensure table exists, creating if necessary

  ## Examples
  iex> alias Igwet.Cache
  iex> Cache.exists(:test)
  false
  iex> Cache.ensure(:test)
  :test
  iex> Cache.exists(:test)
  true
  """
  def ensure(name) do
    if exists(name), do: name, else: create(name)
  end

  def set(name, key, value) do
    value
  end

  def get(name, key) do
    key
  end
end
