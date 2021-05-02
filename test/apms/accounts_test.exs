defmodule Apms.AccountsTest do
  use Apms.DataCase

  alias Apms.Accounts

  describe "users" do
    alias Apms.Accounts.User

    test "list_users/0 returns all users" do
      user = insert(:user)
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = insert(:user)
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} =
               Accounts.create_user(%{email: "some email", password: "some password"})

      assert user.email == "some email"
      assert Argon2.check_pass(user, "some password", hash_key: :password)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(%{email: nil, password: nil})
    end

    test "update_user/2 with valid data updates the user" do
      user = insert(:user)

      assert {:ok, %User{} = user} =
               Accounts.update_user(user, %{
                 email: "some updated email",
                 password: "some updated password"
               })

      assert user.email == "some updated email"
      assert Argon2.check_pass(user, "some updated password", hash_key: :password)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user(user, %{email: nil, password: nil})

      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = insert(:user)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = insert(:user)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "authenticate_user/2 fails with wrong password" do
      user = insert(:user)

      assert {:error, :invalid_credentials} =
               Accounts.authenticate_user(user.email, "another passwrod")
    end

    test "authenticate_user/2 fails with wrong email" do
      insert(:user, email: "user@email.com", password: Argon2.hash_pwd_salt("password"))

      assert {:error, :invalid_credentials} =
               Accounts.authenticate_user("other@email.com", "password")
    end

    test "authenticate_user/2 return the correct user" do
      user = insert(:user, email: "user@email.com", password: Argon2.hash_pwd_salt("password"))

      assert {:ok, user} ==
               Accounts.authenticate_user("user@email.com", "password")
    end
  end
end
