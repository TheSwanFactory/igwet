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

  @doc """
  Set key to value in name

  ## Examples
  iex> alias Igwet.Cache
  iex> Cache.set(:test, "a", "b")
  true
  """
  def set(name, key, value) do
    ensure(name)
    :ets.insert(name, {key, value})
  end

  @doc """
  Get value for key in name

  ## Examples
  iex> alias Igwet.Cache
  iex> Cache.set(:test, "a", "b")
  true
  iex> Cache.get(:test, "a")
  "b"

  """
  def get(name, key) do
    ensure(name)
    row = :ets.lookup(name, key)
    tuple = Enum.at(row, 0)
    Kernel.elem(tuple, 1)
  end
end
