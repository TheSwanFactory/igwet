defmodule Igwet.Network.Edge do
  use Ecto.Schema
  import Ecto.Changeset
  alias Igwet.Network.Edge
  alias Igwet.Network.Node


  schema "edges" do
    belongs_to :subject, Node
    belongs_to :predicate, Node
    belongs_to :object, Node

    timestamps()
  end

  @doc false
  def changeset(%Edge{} = edge, attrs) do
    edge
    |> cast(attrs, [:subject_id])
    |> validate_required([:subject_id])
    |> assoc_constraint(:subject)
  end
end
