defmodule Igwet.Network.Edge do
  use Ecto.Schema
  import Ecto.Changeset
  alias Igwet.Network.Edge


  schema "edges" do
    field :subject_id, :id
    field :predicate_id, :id
    field :object_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Edge{} = edge, attrs) do
    edge
    |> cast(attrs, [])
    |> validate_required([])
  end
end
