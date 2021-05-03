defmodule Apms.TasksTest do
  use Apms.DataCase

  alias Apms.Tasks

  describe "projects" do
    alias Apms.Tasks.Project

    test "list_projects/1 returns all user projects" do
      project = insert(:project)

      assert project.id ==
               project.owner_id |> Tasks.list_projects() |> hd() |> Map.get(:id)
    end

    test "list_projects/1 dont return other user projects" do
      project = insert(:project)
      other_owner_project = insert(:project)

      refute other_owner_project ==
               project.owner_id |> Tasks.list_projects() |> hd() |> Map.get(:id)
    end

    test "get_project!/1 returns the project with given id" do
      project = insert(:project)
      assert Tasks.get_project!(project.id) |> Repo.preload(:owner) == project
    end

    test "create_project/1 with valid data creates a project" do
      user = insert(:user)

      assert {:ok, %Project{} = project} =
               Tasks.create_project(%{owner_id: user.id, name: "project name"})

      assert project.name == "project name"
    end

    test "create_project/1 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Tasks.create_project(%{owner: user})
    end

    test "update_project/2 with valid data updates the project" do
      project = insert(:project)

      assert {:ok, %Project{} = project} =
               Tasks.update_project(project, %{name: "some updated name"})

      assert project.name == "some updated name"
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = insert(:project)
      assert {:error, %Ecto.Changeset{}} = Tasks.update_project(project, %{name: nil})
      assert project == Tasks.get_project!(project.id) |> Repo.preload(:owner)
    end

    test "delete_project/1 deletes the project" do
      project = insert(:project)
      assert {:ok, %Project{}} = Tasks.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = insert(:project)
      assert %Ecto.Changeset{} = Tasks.change_project(project)
    end
  end
end
