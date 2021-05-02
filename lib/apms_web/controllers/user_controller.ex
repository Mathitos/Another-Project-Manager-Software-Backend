defmodule ApmsWeb.UserController do
  use ApmsWeb, :controller

  alias Apms.Accounts
  alias Apms.Accounts.User

  action_fallback ApmsWeb.FallbackController

  def create(conn, %{"email" => email, "password" => password}) do
    with {:ok, %User{} = user} <- Accounts.create_user(%{email: email, password: password}) do
      conn
      |> put_status(:created)
      |> render("show.json", user: user)
    end
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    with {:ok, user} <- Accounts.authenticate_user(email, password),
         {:ok, token, _claims} <- ApmsWeb.Guardian.encode_and_sign(user) do
      conn
      |> put_view(ApmsWeb.JwtView)
      |> render("jwt.json", jwt: token)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Login error"})
    end
  end
end
