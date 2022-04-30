defmodule IgwetWeb.PageView do
  use IgwetWeb, :view

  def title(assigns) do
    IgwetWeb.LayoutView.title(assigns)
  end
end
