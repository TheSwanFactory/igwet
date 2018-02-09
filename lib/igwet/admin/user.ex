defmodule Igwet.Admin.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Igwet.Admin.User
  alias Igwet.Repo


  schema "users" do
    field :authid, :string
    field :avatar, :string
    field :last_login, :naive_datetime
    field :name, :string

    timestamps()
  end

  @doc "Return user, creating it if it does not exist"
  def find_or_create(%User{} = user) do
    query = User |> where([u], u.authid == ^user.authid)
    if !Repo.one(query)  do
      Repo.insert(user)
    end
    Repo.one(query)
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:authid, :name, :avatar, :last_login])
    |> validate_required([:authid, :name, :avatar, :last_login])
  end
end
