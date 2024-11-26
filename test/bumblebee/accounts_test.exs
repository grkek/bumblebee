defmodule Bumblebee.AccountsTest do
  use Bumblebee.DataCase

  alias Bumblebee.Accounts

  describe "users" do
    alias Bumblebee.Accounts.User

    import Bumblebee.AccountsFixtures

    @invalid_attrs %{first_name: nil, last_name: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{first_name: "some first_name", last_name: "some last_name"}

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.first_name == "some first_name"
      assert user.last_name == "some last_name"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{first_name: "some updated first_name", last_name: "some updated last_name"}

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "streams" do
    alias Bumblebee.Accounts.Stream

    import Bumblebee.AccountsFixtures

    @invalid_attrs %{first_name: nil, last_name: nil}

    test "list_streams/0 returns all streams" do
      stream = stream_fixture()
      assert Accounts.list_streams() == [stream]
    end

    test "get_stream!/1 returns the stream with given id" do
      stream = stream_fixture()
      assert Accounts.get_stream!(stream.id) == stream
    end

    test "create_stream/1 with valid data creates a stream" do
      valid_attrs = %{first_name: "some first_name", last_name: "some last_name"}

      assert {:ok, %Stream{} = stream} = Accounts.create_stream(valid_attrs)
      assert stream.first_name == "some first_name"
      assert stream.last_name == "some last_name"
    end

    test "create_stream/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_stream(@invalid_attrs)
    end

    test "update_stream/2 with valid data updates the stream" do
      stream = stream_fixture()
      update_attrs = %{first_name: "some updated first_name", last_name: "some updated last_name"}

      assert {:ok, %Stream{} = stream} = Accounts.update_stream(stream, update_attrs)
      assert stream.first_name == "some updated first_name"
      assert stream.last_name == "some updated last_name"
    end

    test "update_stream/2 with invalid data returns error changeset" do
      stream = stream_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_stream(stream, @invalid_attrs)
      assert stream == Accounts.get_stream!(stream.id)
    end

    test "delete_stream/1 deletes the stream" do
      stream = stream_fixture()
      assert {:ok, %Stream{}} = Accounts.delete_stream(stream)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_stream!(stream.id) end
    end

    test "change_stream/1 returns a stream changeset" do
      stream = stream_fixture()
      assert %Ecto.Changeset{} = Accounts.change_stream(stream)
    end
  end
end
