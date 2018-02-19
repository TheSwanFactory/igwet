defmodule Igwet.AuthTest do
  #require IEx; #IEx.pry
  use Igwet.DataCase
  doctest Igwet.Admin.User.FromAuth

  describe "auth" do
    alias Igwet.Admin.User.FromAuth
    alias Igwet.Admin.User
    alias Igwet.Network
    alias Ueberauth.Auth

    @valid_cred %{other: %{password: "pw", password_confirmation: "pw"}}

    @invalid_cred %{@valid_cred | other: %{}}

    @valid_info %{name: "My Name", image: "url", email: "email@me.com"}

    @valid_auth %Auth{credentials: @valid_cred, info: @valid_info, uid: "me"}

    @invalid_auth %Auth{credentials: @invalid_cred, provider: :identity}

    test "find_or_create/1 returns %User" do
      Network.create_node(@valid_info)
      {:ok, user} = FromAuth.find_or_create(@valid_auth)
      %User{authid: uid, name: name, avatar: url, email: email, node: node} = user
      assert uid === "me"
      assert name === "My Name"
      assert url === "url"
      assert email == "email@me.com"
      assert node.email == "email@me.com"
    end

    test "find_or_create/1 errors if provider" do
      {:error, msg} = FromAuth.find_or_create(@invalid_auth)
      assert msg === "Password Required"
    end
  end
end
