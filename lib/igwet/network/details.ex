
defmodule Details do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :duration, :integer
    field :recurrence, :integer
    field :parent_id, :binary_id
  end

  @doc false
  def changeset(details, attrs) do
    details
    |> cast(attrs, [:duration, :recurrence, :parent_id])
  end
end
