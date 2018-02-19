defmodule Igwet.Admin.User.FromAuth do
  # @compile if Mix.env == :test, do: :export_all
  require IEx;
  require Logger
  require Poison

  import Ecto.Query, warn: false

  alias Ueberauth.Auth
  alias Igwet.Admin
  alias Igwet.Admin.User
  alias Igwet.Network.Node
  alias Igwet.Repo

  @doc """
  Generates user from provider response if valid password
  """
  def find_or_create(%Auth{provider: :identity} = auth) do
    case validate_pass(auth.credentials) do
      :ok -> {:ok, auth_user(auth)}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Generates user from anonymous auth data
  """
  def find_or_create(%Auth{} = auth) do
    {:ok, auth_user(auth)}
  end

  defp auth_user(auth) do
    info = basic_info(auth)
    user = Admin.find_or_create_user(info)
    node = Node |> where([n], n.email == ^user.email) |> Repo.one()
    if node do
       %User{ user| node_id: node}
    else
      user
    end
  end

  defp basic_info(auth) do
    info = auth.info
    %{
      authid: auth.uid,
      avatar: avatar_from_auth(auth),
      email: Map.get(info, :email),
      email_verified: Map.get(info, :email_verified),
      family_name: Map.get(info, :family_name),
      given_name: Map.get(info, :given_name),
      name: name_from_auth(auth),
      nickname: Map.get(info, :nickname)
    }
  end

  # github does it this way
  defp avatar_from_auth( %{info: %{urls: %{avatar_url: image}} }), do: image

  # facebook does it this way
  defp avatar_from_auth( %{info: %{image: image} }), do: image

  # default case if nothing matches
  defp avatar_from_auth( auth ) do
    Logger.warn auth.provider <> " needs to find an avatar URL!"
    Logger.debug(Poison.encode!(auth))
    nil
  end

  defp name_from_auth(auth) do
    if auth.info.name do
      auth.info.name
    else
      name = [auth.info.first_name, auth.info.last_name]
      |> Enum.filter(&(&1 != nil and &1 != ""))

      cond do
        length(name) == 0 -> auth.info.nickname
        true -> Enum.join(name, " ")
      end
    end
  end

  defp validate_pass(%{other: %{password: ""}}) do
    {:error, "Password required"}
  end
  defp validate_pass(%{other: %{password: pw, password_confirmation: pw}}) do
    :ok
  end
  defp validate_pass(%{other: %{password: _}}) do
    {:error, "Passwords do not match"}
  end
  defp validate_pass(_), do: {:error, "Password Required"}
end
