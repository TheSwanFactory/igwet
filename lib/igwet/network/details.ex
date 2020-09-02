
defmodule Details do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :capacity, :integer
    field :current, :integer
    field :duration, :integer
    field :recurrence, :integer
    field :parent_id, :binary_id
  end

  @doc false
  def changeset(details, attrs) do
    details
    |> cast(attrs, [:capacity, :current, :duration, :recurrence, :parent_id])
  end
end
