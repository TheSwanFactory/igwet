defmodule IgwetWeb.LayoutView do
  use IgwetWeb, :view

  def title(assigns) do
    Enum.at(Regex.run(~r/Elixir\.IgwetWeb\.(.*)View/, to_string(__MODULE__)),1)
  end
end
