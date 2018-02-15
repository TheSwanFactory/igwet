defmodule IgwetWeb.PageController do
  use IgwetWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:name, "IGWET")
    |> assign(:version, Application.spec(:igwet, :vsn))
    |> assign(:current_user, get_session(conn, :current_user))
    |> render("index.html")
  end
end
