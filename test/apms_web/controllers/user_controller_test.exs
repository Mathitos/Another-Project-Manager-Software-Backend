defmodule ApmsWeb.UserControllerTest do
  use ApmsWeb.ConnCase

  alias Apms.Repo
  alias Apms.Accounts.User

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "/api/v1/sign_up" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, "api/v1/sign_up", %{email: "user@email.com", password: "password"})

      assert %{"id" => id} = json_response(conn, 201)["data"]

      assert %User{} = Repo.get(User, id)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, "api/v1/sign_up", %{email: "user@email.com", password: nil})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "api/v1/sign_in" do
    test "return an jwt token when the credentials are valid", %{conn: conn} do
      insert(:user, email: "user@email.com", password: Argon2.hash_pwd_salt("password"))

      conn =
        post(conn, "api/v1/sign_in", %{
          "email" => "user@email.com",
          "password" => "password"
        })

      assert Map.has_key?(json_response(conn, 200), "jwt")
    end

    test "return an error when credentials are invalid", %{conn: conn} do
      insert(:user, email: "user@email.com", password: Argon2.hash_pwd_salt("password"))

      conn =
        post(conn, "api/v1/sign_in", %{
          "email" => "user@email.com",
          "password" => "password2"
        })

      assert json_response(conn, 401)["errors"] != %{}
    end
  end
end
