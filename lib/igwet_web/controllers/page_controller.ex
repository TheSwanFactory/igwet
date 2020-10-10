defmodule IgwetWeb.PageController do
  use IgwetWeb, :controller
  require Logger

  def index(conn, params) do
    Logger.debug("** PageController.index" <> inspect(params))
    conn
    |> assign(:name, "IGWET")
    |> assign(:version, Application.spec(:igwet, :vsn))
    |> assign(:current_user, get_session(conn, :current_user))
    |> render("index.html")
  end
end
