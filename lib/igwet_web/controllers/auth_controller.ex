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
        result = conn
        |> put_flash(:info, msg)
        |> put_session(:current_user, user)
        |> redirect(to: "/")
        Logger.debug("** AuthController.callback.result\n" <> inspect(result))
        result
      {:error, reason} ->
        Logger.debug("** AuthController.callback.reason" <> inspect(reason))
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end
end
