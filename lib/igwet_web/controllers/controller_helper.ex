defmodule IgwetWeb.ControllerHelper do
  import Plug.Conn
  import Phoenix.Controller
  alias IgwetWeb.ErrorView
  alias Igwet.Admin
  alias Igwet.Admin.User
  alias Igwet.Network

  def test_user(key) do
    %User{name: "Test #{key} User", node: Network.seed_node(key)}
  end

  def get_user(conn) do
    case Mix.env do
      :test -> test_user(:superuser)
      _ -> get_session(conn, :current_user)
    end
  end

  def require_auth(conn, _params) do
    user = get_user(conn)
    case user do
      nil -> conn |> redirect(to: "/auth/auth0") |> halt
      _ -> conn |> assign(:current_user, user)
    end
  end

  def require_admin(conn, _params) do
    user = get_user(conn)
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
