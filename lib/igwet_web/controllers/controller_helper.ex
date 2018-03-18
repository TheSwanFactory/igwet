defmodule IgwetWeb.ControllerHelper do
  import Plug.Conn
  import Phoenix.Controller
  alias IgwetWeb.ErrorView
  alias Igwet.Admin

  def get_user(conn) do
    case Application.get_env(:igwet, :env) do
      :test -> Admin.test_admin_user(true)
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
      true ->
        conn |> assign(:current_user, user)

      nil ->
        conn
        |> put_status(401)
        |> render(
          ErrorView,
          :"401",
          message: "There is no user with a valid contact currently logged in"
        )
        |> halt

      false ->
        conn
        |> put_status(401)
        |> render(
          ErrorView,
          :"401",
          message:
            "The contact for this login does not have the Administrator privilege necessary to view this page"
        )
        |> halt
    end
  end
end
