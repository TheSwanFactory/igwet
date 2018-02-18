defmodule Igwet.Network.Node do
  use Ecto.Schema
  import Ecto.Changeset
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

    timestamps()
  end

  @doc false
  def changeset(%Node{} = node, attrs) do
    node
    |> cast(attrs, [:name, :about, :email, :phone, :key])
    |> validate_required([:name])
  end
end
