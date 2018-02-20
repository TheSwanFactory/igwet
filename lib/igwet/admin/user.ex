defmodule Igwet.Admin.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Igwet.Admin.User
  alias Igwet.Network.Node

  schema "users" do
    field :authid, :string
    field :avatar, :string
    field :email, :string
    field :email_verified, :boolean
    field :family_name, :string
    field :given_name, :string
    field :last_login, :naive_datetime
    field :name, :string
    field :nickname, :string

    belongs_to :node, Node

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:authid, :avatar, :email, :email_verified, :family_name, :given_name, :last_login, :name, :nickname])
    |> validate_required([:authid, :name])
    |> unique_constraint(:authid)
  end
end
