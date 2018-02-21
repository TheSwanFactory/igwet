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
    conn
  end
end
