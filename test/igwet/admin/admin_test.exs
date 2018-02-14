defmodule Igwet.AdminTest do
  use Igwet.DataCase
  doctest Igwet.Admin

  alias Igwet.Admin

  describe "users" do
    alias Igwet.Admin.User

    @valid_attrs %{authid: "some authid", avatar: "some avatar", last_login: ~N[2010-04-17 14:00:00.000000], name: "some name"}
    @update_attrs %{authid: "some updated authid", avatar: "some updated avatar", last_login: ~N[2011-05-18 15:01:01.000000], name: "some updated name"}
    @invalid_attrs %{authid: nil, avatar: nil, last_login: nil, name: nil}
    @next_attrs %{authid: "next authid", avatar: "next avatar", last_login: ~N[2010-04-17 14:00:00.000000], name: "next name"}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Admin.create_user()

      user
    end

    def first() do
      user = user_fixture()
      Admin.get_user!(user.id)
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Admin.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Admin.get_user!(user.id) == user
    end

    test "find_or_create_user/1 with existing data returns that user" do
      first = first()
      assert user = Admin.find_or_create_user(@valid_attrs)
      assert %User{} = user
      assert user.id == first.id
    end

    test "find_or_create_user/1 with new data creates user" do
      first = first()
      assert user = Admin.find_or_create_user(@next_attrs)
      assert %User{} = user
      assert user.id != first.id
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Admin.create_user(@valid_attrs)
      assert user.authid == "some authid"
      assert user.avatar == "some avatar"
      assert user.last_login == ~N[2010-04-17 14:00:00.000000]
      assert user.name == "some name"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Admin.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Admin.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.authid == "some updated authid"
      assert user.avatar == "some updated avatar"
      assert user.last_login == ~N[2011-05-18 15:01:01.000000]
      assert user.name == "some updated name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Admin.update_user(user, @invalid_attrs)
      assert user == Admin.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Admin.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Admin.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Admin.change_user(user)
    end
  end
end
