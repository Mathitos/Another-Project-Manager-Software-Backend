defmodule Apms.Factory do
  alias Apms.Repo

  def build(:user) do
    %Apms.Accounts.User{
      email: "user#{uniq_number()}@email.com",
      password: Argon2.hash_pwd_salt("password")
    }
  end

  def build(:project) do
    %Apms.Tasks.Project{
      name: "project #{uniq_number()}",
      owner: build(:user)
    }
  end

  def build(:task) do
    %Apms.Tasks.Task{
      name: "task #{uniq_number()}",
      description: "task description",
      project: build(:project)
    }
  end

  defp uniq_number(), do: System.unique_integer([:positive])

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
