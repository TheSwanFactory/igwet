defmodule IgwetWeb.AuthController do
  use IgwetWeb, :controller
  plug(Ueberauth)
  alias Igwet.Admin.User.FromAuth
  require Logger

  def logout(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case FromAuth.find_or_create(auth) do
      {:ok, user} ->
        #Logger.debug("** AuthController.callback.user" <> inspect(user))
        msg = "Successfully authenticated #{user.name} <#{user.email}> as node '#{user.node.key}'."
        Logger.debug("** AuthController.callback.msg\n" <> msg)
        conn1 = put_flash(conn, :info, msg)
        conn2 = put_session(conn1, :current_user, user)
        Logger.debug("** AuthController.callback.user\n" <> inspect(user))
        Logger.debug("** AuthController.callback.node\n" <> inspect(user.node))
        #Logger.debug("** AuthController.callback.conn2\n" <> inspect(conn2))
        Logger.debug("** AuthController.callback.REDIRECT\n")
        conn3 = redirect(conn2, to: "/")
        Logger.debug("** AuthController.callback.conn3\n" <> inspect(conn3))
        conn3
      {:error, reason} ->
        Logger.debug("** AuthController.callback.reason" <> inspect(reason))
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end
end
