defmodule Igwet.Admin do
  @moduledoc """
  The Admin context.
  """

  import Ecto.Query, warn: false
  alias Igwet.Repo
  alias Igwet.Admin.User
  alias Igwet.Network
  require Logger

  def test_admin_user(is_admin) do
    if is_admin do
      admin_name = Application.get_env(:igwet, :admin_user)
      %User{name: "Test Admin User", node: Network.get_first_node!(:name, admin_name)}
    else
      %User{name: "Test Non-Admin User", node: Network.get_first_node!(:name, "group")}
    end
  end

  @doc """
  Check whether this user is a Site Administrator.

  ## Examples
      iex> user = Igwet.Admin.find_or_create_user(%{authid: "1", name: "I"})
      iex> Igwet.Admin.is_admin(user)
      nil

  """
  def is_admin(user) do
    cond do
      is_nil user -> nil
      !Ecto.assoc_loaded?(user.node) -> nil
      true -> Network.node_is_admin?(user.node)
    end
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> n = length(Igwet.Admin.list_users())
      iex> Igwet.Admin.find_or_create_user(%{authid: "1", name: "I"})
      iex> m = length(Igwet.Admin.list_users())
      iex> m - n
      1

  """
  def list_users do
    Repo.all(User)
  end

  @doc ~S"""
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> user = Igwet.Admin.find_or_create_user(%{authid: "1", name: "I"})
      iex> got = Igwet.Admin.get_user!(user.id)
      iex> got == user
      true
  """
  def get_user!(id) do
    User
    |> Repo.get!(id)
  end
  @doc """
  Creates a user.

  ## Examples

      iex> {:ok, user} = Igwet.Admin.create_user(%{authid: "1", name: "I"})
      iex> user.__struct__
      Igwet.Admin.User
      iex> {:error, error} = Igwet.Admin.create_user(%{name: "I"})
      iex> elem(error.errors[:authid],0)
      "can't be blank"

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Return user, creating it if it does not exist.

  ## Examples

      iex> user = Igwet.Admin.find_or_create_user(%{authid: "1", name: "I"})
      iex> user.__struct__
      Igwet.Admin.User


  """
  def find_or_create_user(attrs) do
    query = User |> where([u], u.authid == ^attrs.authid)

    if !Repo.one(query) do
      create_user(attrs)
    end

    Repo.one(query)
  end

  @doc """
  Updates a user.

  ## Examples

      iex> user = Igwet.Admin.find_or_create_user(%{authid: "1", name: "I"})
      iex> Igwet.Admin.update_user(user, %{name: "U"})
      iex> updated = Igwet.Admin.get_user!(user.id)
      iex> updated.name
      "U"

      iex> user = Igwet.Admin.find_or_create_user(%{authid: "1", name: "I"})
      iex> {:error, error} = Igwet.Admin.update_user(user, %{name: 456})
      iex> elem(error.errors[:name],0)
      "is invalid"

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc ~S"""
  Deletes a User.

  ## Examples

      iex> user = Igwet.Admin.find_or_create_user(%{authid: "1", name: "I"})
      iex> {:ok, deleted} = Igwet.Admin.delete_user(user)
      iex> deleted.id == user.id
      true

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> user = Igwet.Admin.find_or_create_user(%{authid: "1", name: "I"})
      iex> diff = Igwet.Admin.change_user(user)
      iex> %Ecto.Changeset{changes: changes} = diff
      iex> changes
      %{}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
