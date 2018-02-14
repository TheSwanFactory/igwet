defmodule Igwet.Network.Node do
  use Ecto.Schema
  import Ecto.Changeset
  alias Igwet.Network.Node


  schema "nodes" do
    field :about, :string
    field :email, :string
    field :key, :string
    field :name, :string
    field :phone, :string

    timestamps()
  end

  @doc false
  def changeset(%Node{} = node, attrs) do
    node
    |> cast(attrs, [:name, :about, :email, :phone, :key])
    |> validate_required([:name, :about, :email, :phone, :key])
  end
end
