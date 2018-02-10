defmodule Igwet.Admin do
  @moduledoc """
  The Admin context.
  """

  import Ecto.Query, warn: false
  alias Igwet.Repo

  alias Igwet.Admin.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> Igwet.Admin.find_or_create_user(%{authid: "1", name: "I"})
      iex> Igwet.Admin.list_users()
      [%Igwet.Admin.User{}]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> user = Igwet.Admin.find_or_create_user(%{authid: "1", name: "I"})
      %Igwet.Admin.User{}
      iex> Igwet.Admin.get_user!(user.id)
      %Igwet.Admin.User{}
      iex> Igwet.Admin.get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

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

      iex> Igwet.Admin.find_or_create_user(%{authid: "1", name: "I"})
      %Igwet.Admin.User{name: "I"}


  """
  def find_or_create_user(attrs) do
    query = User |> where([u], u.authid == ^attrs.authid)
    if !Repo.one(query)  do
      create_user(attrs)
    end
    Repo.one(query)
  end

  @doc """
  Updates a user.

  ## Examples

      iex> user = Igwet.Admin.find_or_create_user(%{authid: "1", name: "I"})
      iex> Igwet.Admin.update_user(user, %{name: "Jane"})
      {:ok, %Igwet.Admin.User{name: "Jane"}}

      iex> user = Igwet.Admin.find_or_create_user(%{authid: "1", name: "I"})
      iex> Igwet.Admin.update_user(user, %{field: 456})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> user = Igwet.Admin.find_or_create_user(%{authid: "1", name: "I"})
      iex> Igwet.Admin.delete_user(user)
      {:ok, %Igwet.Admin.User{}}
      iex> Igwet.Admin.delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> user = Igwet.Admin.find_or_create_user(%{authid: "1", name: "I"})
      iex> Igwet.Admin.change_user(user)
      %Ecto.Changeset{changes: %{authid: "1", name: "I"}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
