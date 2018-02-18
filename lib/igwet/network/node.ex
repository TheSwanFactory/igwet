defmodule Igwet.Network.Node do
  use Ecto.Schema
  import Ecto.Changeset
  alias Igwet.Admin.User
  alias Igwet.Network.Address
  alias Igwet.Network.Edge
  alias Igwet.Network.Node

  schema "nodes" do
    field :about, :string
    field :email, :string
    field :key, :string
    field :meta, :string
    field :name, :string
    field :phone, :string
    field :url, :string

    belongs_to :address, Address
    has_many :edges, Edge, foreign_key: :subject_id
    has_one :user, User

    timestamps()
  end

  @doc false
  def changeset(%Node{} = node, attrs) do
    node
    |> cast(attrs, [:name, :about, :email, :phone, :key])
    |> validate_required([:name])
  end
end
