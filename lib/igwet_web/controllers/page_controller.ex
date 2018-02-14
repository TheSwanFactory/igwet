defmodule IgwetWeb.PageController do
  use IgwetWeb, :controller

  def index(conn, _params) do
    project = Igwet.Mixfile.project

    conn
    |> assign(:name, "IGWET")
    |> assign(:version, project[:version])
    |> assign(:current_user, get_session(conn, :current_user))
    |> render("index.html")
  end
end
