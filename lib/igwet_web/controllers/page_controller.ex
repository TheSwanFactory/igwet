defmodule IgwetWeb.PageController do
  use IgwetWeb, :controller

  def index(conn, _params) do
    project = Igwet.Mixfile.project

    conn
    |> assign(:version, project[:version])
    |> assign(:name, "IGWET")
    |> render("index.html")
  end
end
