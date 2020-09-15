defmodule IgwetWeb.AuthController do
  use IgwetWeb, :controller

  plug(Ueberauth)

  alias Igwet.Admin.User.FromAuth
  alias Igwet.DataMigrator
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
        if (is_nil user.node.type) do
          Logger.warn("Running migration to inline types\n#{inspect(user.node)}")
          DataMigrator.run()
        end
        conn
        |> put_flash(
          :info,
          "Successfully authenticated #{user.name} <#{user.email}> as node '#{user.node.key}'."
        )
        |> put_session(:current_user, user)
        |> redirect(to: "/")

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end
end
