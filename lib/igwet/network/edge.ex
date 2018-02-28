defmodule Igwet.Network.Edge do
  use Ecto.Schema
  import Ecto.Changeset
  alias Igwet.Network.Edge
  alias Igwet.Network.Node

  @foreign_key_type Ecto.UUID

  schema "edges" do
    belongs_to(:subject, Node)
    belongs_to(:predicate, Node)
    belongs_to(:object, Node)

    timestamps()
  end

  @doc false
  def changeset(%Edge{} = edge, attrs) do
    relations = [:subject_id, :predicate_id, :object_id]

    edge
    |> cast(attrs, relations)
    |> validate_required(relations)
    |> assoc_constraint(:subject)
    |> assoc_constraint(:predicate)
    |> assoc_constraint(:object)
  end
end
