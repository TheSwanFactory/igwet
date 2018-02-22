defmodule IgwetWeb.ControllerHelper do
  import Plug.Conn
  import Phoenix.Controller
  alias IgwetWeb.ErrorView
  alias Igwet.Admin.User
  alias Igwet.Admin
  alias Igwet.Network

  def test_user() do
    keys = Application.get_env(:igwet, :seed_keys)
    node = Network.get_node_by_key!(keys[:superuser])
    %User{name: "Test User", node: node}
  end

  def require_auth(conn, _params) do
    if Mix.env == :test do
      conn |> assign(:current_user, test_user())
    else
      user = get_session(conn, :current_user)
      case user do
        nil -> conn |> redirect(to: "/auth/auth0") |> halt
        _ -> conn |> assign(:current_user, user)
      end
    end
  end

  def require_admin(conn, _params) do
    if Mix.env == :test do
      conn |> assign(:current_user, test_user())
    else
      user = get_session(conn, :current_user)
      case Admin.is_admin(user) do
        true -> conn |> assign(:current_user, user)
        nil ->
          conn
          |> put_status(401)
          |> render(ErrorView, :"401", message: "There is no user with a valid contact currently logged in")
          |> halt
        false ->
          conn
          |> put_status(401)
          |> render(ErrorView, :"401", message: "The contact for this login does not have the Administrator privilege necessary to view this page")
          |> halt
      end
    end
  end

end
