defmodule IgwetWeb.ControllerHelper do
  import Plug.Conn
  import Phoenix.Controller
  alias Igwet.Admin
  alias Igwet.Network

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

  def unauthorized(conn, message) do
    last_path =
      case conn.method do
        "GET" -> true
        _ -> false
      end
      |> case do
        false ->
          nil

        true ->
          conn.request_path <>
            if byte_size(conn.query_string) > 0 do
              "?" <> conn.query_string
            else
              ""
            end
      end

    text = "#{last_path}: #{message}"

    conn
    |> put_session(:last_path, last_path)
    |> put_flash(:error, text)
    |> redirect(to: "/")
  end

  def require_admin(conn, _params) do
    user = get_user(conn)

    case Admin.is_admin(user) do
      true ->
        conn
        |> assign(:current_user, user)

      nil ->
        conn
        |> assign(:current_user, nil)
        |> unauthorized("There is no user with a valid contact currently logged in.")

      false ->
        conn
        |> assign(:current_user, user)
        |> unauthorized(
          "The contact for this login does not have the Administrator privilege necessary to view this page."
        )
    end
  end

  def require_login(conn, _params) do
    user = get_user(conn)
    if (nil != user) do
      conn
      |> assign(:current_user, user)
    else
      conn
      |> assign(:current_user, nil)
      |> unauthorized("There is no user with a valid contact currently logged in.")
    end
  end

end
