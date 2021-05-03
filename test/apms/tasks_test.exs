defmodule Apms.TasksTest do
  use Apms.DataCase

  alias Apms.Tasks
  alias Apms.Tasks.{Project, Task}

  describe "projects" do
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

  describe "tasks" do
    test "list_tasks/1 returns all tasks for given project" do
      task = insert(:task)
      assert Tasks.list_tasks(task.project_id) |> Repo.preload(project: :owner) == [task]
    end

    test "list_tasks/1 dont returns tasks from other projects" do
      project = insert(:project)
      insert(:task)
      assert Tasks.list_tasks(project.id) == []
    end

    test "list_tasks/1 return list ordered by task order field" do
      project = insert(:project)
      insert(:task, project: project, order: 1)
      insert(:task, project: project, order: 3)
      insert(:task, project: project, order: 2)

      assert [%{order: 1}, %{order: 2}, %{order: 3}] = Tasks.list_tasks(project.id)
    end

    test "get_task!/1 returns the task with given id" do
      task = insert(:task)
      assert Tasks.get_task!(task.id) |> Repo.preload(project: [:owner]) == task
    end

    test "create_task/1 with valid data creates a task" do
      project = insert(:project)

      assert {:ok, %Task{} = task} =
               Tasks.create_task(%{
                 name: "some name",
                 description: "some description",
                 project_id: project.id
               })

      assert task.description == "some description"
      assert task.name == "some name"
      assert task.project_id == project.id
    end

    test "create_task/1 add an task to the end of prroject" do
      project = insert(:project)
      insert(:task, project: project, order: 1)
      insert(:task, project: project, order: 99)

      assert {:ok, %Task{} = task} =
               Tasks.create_task(%{
                 name: "some name",
                 description: "some description",
                 project_id: project.id,
                 order: 5
               })

      assert task.order == 100
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task(%{name: nil})
    end

    test "update_task/2 with valid data updates the task" do
      task = insert(:task)

      assert {:ok, %Task{} = task} =
               Tasks.update_task(task, %{
                 name: "some updated name",
                 description: "some updated description"
               })

      assert task.description == "some updated description"
      assert task.name == "some updated name"
    end

    test "update_task/2 changing the order also change relative tasks order" do
      project = insert(:project)
      task1 = insert(:task, project: project, order: 1)
      task2 = insert(:task, project: project, order: 2)
      task3 = insert(:task, project: project, order: 3)
      task4 = insert(:task, project: project, order: 4)
      task5 = insert(:task, project: project, order: 5)

      assert {:ok, _} =
               Tasks.update_task(task1, %{
                 name: "some updated name",
                 description: "some updated description",
                 order: 3
               })

      old_task1 = Repo.get(Task, task1.id)
      assert old_task1.description == "some updated description"
      assert old_task1.name == "some updated name"
      assert old_task1.order == 3

      assert %{order: 1} = Repo.get(Task, task2.id)
      assert %{order: 2} = Repo.get(Task, task3.id)
      assert %{order: 4} = Repo.get(Task, task4.id)
      assert %{order: 5} = Repo.get(Task, task5.id)

      assert {:ok, _} =
               Tasks.update_task(task5, %{
                 order: 3
               })

      assert %{order: 4} = Repo.get(Task, task1.id)
      assert %{order: 5} = Repo.get(Task, task4.id)
      assert %{order: 3} = Repo.get(Task, task5.id)
    end

    test "can't update task order to less than 1" do
      task = insert(:task, order: 5)

      assert {:ok, _} =
               Tasks.update_task(task, %{
                 name: "some updated name",
                 description: "some updated description",
                 order: 0
               })

      updated_task = Repo.get(Task, task.id)
      assert updated_task.description == "some updated description"
      assert updated_task.name == "some updated name"
      assert updated_task.order == 1

      assert {:ok, _} =
               Tasks.update_task(updated_task, %{
                 order: -2
               })

      re_updated_task = Repo.get(Task, updated_task.id)
      assert re_updated_task.order == 1
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = insert(:task)
      assert {:error, %Ecto.Changeset{}} = Tasks.update_task(task, %{name: nil})
      refute Task |> Repo.get(task.id) |> Map.get(:name) |> is_nil()
    end

    test "delete_task/1 deletes the task" do
      task = insert(:task)
      assert {:ok, %Task{}} = Tasks.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(task.id) end
    end
  end
end
