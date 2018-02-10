defmodule Igwet.Admin.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Igwet.Admin.User


  schema "users" do
    field :authid, :string
    field :avatar, :string
    field :last_login, :naive_datetime
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:authid, :name, :avatar, :last_login])
    |> validate_required([:authid, :name])
  end
end
