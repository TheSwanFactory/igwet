defmodule IgwetWeb.ControllerHelper do
  import Plug.Conn
  import Phoenix.Controller
  alias Igwet.Admin.User

  def require_auth(conn, _params) do
    if Mix.env == :test do
      user = %User{name: "Test User"}
      conn |> assign(:current_user, user)
    else
      user = get_session(conn, :current_user)
      case user do
        nil -> conn |> redirect(to: "/auth/auth0") |> halt
        _ -> conn |> assign(:current_user, user)
      end
    end
  end

  def require_admin(conn, params) do
    conn = require_auth(conn, params)
    user = get_session(conn, :current_user)
    node = user.node
    if !node do
      conn
      |> put_status(401)
      |> render(ErrorView, :"401", message: "The email for this login is not associated with an active contact")
    else if !Node.is_admin(node) do
      conn
      |> put_status(401)
      |> render(ErrorView, :"401", message: "The contact for this login does not have the Administrator privilege necessary to view this page")
    end
    conn
  end
end
