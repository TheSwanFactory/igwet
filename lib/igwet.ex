defmodule Igwet do
  require Protocol
  Protocol.derive(Jason.Encoder, RuntimeError)
  Protocol.derive(Jason.Encoder, FunctionClauseError)
  Protocol.derive(Jason.Encoder, Ecto.NoResultsError)
  Protocol.derive(Jason.Encoder, Ecto.MultipleResultsError)
  @moduledoc """
  Igwet keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
end
