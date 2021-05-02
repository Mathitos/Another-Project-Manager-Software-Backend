defmodule Apms.Factory do
  alias Apms.Repo

  def build(:user) do
    %Apms.Accounts.User{
      email: "user@email.com",
      password: Argon2.hash_pwd_salt("password")
    }
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
