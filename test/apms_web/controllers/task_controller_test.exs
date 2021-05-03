defmodule ApmsWeb.TaskControllerTest do
  use ApmsWeb.ConnCase

  alias Apms.Tasks.Task

  setup %{conn: conn} do
    user = insert(:user)

    conn =
      conn
      |> add_auth_header(user)
      |> put_req_header("accept", "application/json")

    {:ok, conn: conn, user: user}
  end

  describe "index" do
    test "list all tasks for given project", %{conn: conn, user: user} do
      project = insert(:project, owner: user)
      task1 = insert(:task, project: project)
      task2 = insert(:task, project: project)

      conn = get(conn, "api/v1/project/#{project.id}/task")

      assert %{"id" => task1.id, "name" => task1.name, "description" => task1.description} in json_response(
               conn,
               200
             )["data"]

      assert %{"id" => task2.id, "name" => task2.name, "description" => task2.description} in json_response(
               conn,
               200
             )["data"]
    end

    test "list all tasks for given project corrrectly ordered", %{conn: conn, user: user} do
      project = insert(:project, owner: user)
      %{id: task1_id} = insert(:task, project: project, order: 1)
      %{id: task3_id} = insert(:task, project: project, order: 3)
      %{id: task2_id} = insert(:task, project: project, order: 2)

      conn = get(conn, "api/v1/project/#{project.id}/task")

      assert [%{"id" => ^task1_id}, %{"id" => ^task2_id}, %{"id" => ^task3_id}] =
               json_response(
                 conn,
                 200
               )["data"]
    end

    test "shouldn't list task from different projects", %{conn: conn, user: user} do
      project = insert(:project, owner: user)
      task1 = insert(:task, project: project)
      task2 = insert(:task)

      conn = get(conn, "api/v1/project/#{project.id}/task")

      assert %{"id" => task1.id, "name" => task1.name, "description" => task1.description} in json_response(
               conn,
               200
             )["data"]

      refute %{"id" => task2.id, "name" => task2.name, "description" => task2.description} in json_response(
               conn,
               200
             )["data"]
    end
  end

  describe "create" do
    test "can create task for given project if user owns the project", %{conn: conn, user: user} do
      project = insert(:project, owner: user)

      conn =
        post(conn, "api/v1/project/#{project.id}/task", %{
          "name" => "task name",
          "description" => "task description"
        })

      assert %{"id" => id} =
               json_response(
                 conn,
                 201
               )["data"]

      refute Task |> Repo.get_by(id: id, project_id: project.id) |> is_nil()
    end

    test "shouldn't create task for given project if user doesn't owns the project", %{
      conn: conn
    } do
      project = insert(:project)

      conn =
        post(conn, "api/v1/project/#{project.id}/task", %{
          "name" => "task name",
          "description" => "task description"
        })

      assert json_response(conn, 422)["errors"] != %{}

      assert Task |> Repo.all() == []
    end

    test "shouldn't create task is invalid parameters are given", %{
      conn: conn,
      user: user
    } do
      project = insert(:project, owner: user)

      conn =
        post(conn, "api/v1/project/#{project.id}/task", %{
          "name" => nil,
          "description" => "task description"
        })

      assert json_response(conn, 422)["errors"] != %{}

      assert Task |> Repo.all() == []
    end
  end

  describe "update" do
    test "should update task", %{conn: conn, user: user} do
      project = insert(:project, owner: user)
      task = insert(:task, project: project)

      conn =
        put(conn, "api/v1/project/#{project.id}/task/#{task.id}", %{
          "name" => "updated task name",
          "description" => "updated task description"
        })

      assert %{"id" => id} =
               json_response(
                 conn,
                 200
               )["data"]

      updated_task = Repo.get(Task, id)
      assert updated_task.name == "updated task name"
      assert updated_task.description == "updated task description"
    end

    test "shouldn't allow update tasks from other users projects", %{conn: conn} do
      project = insert(:project)
      task = insert(:task, project: project)

      conn =
        put(conn, "api/v1/project/#{project.id}/task/#{task.id}", %{
          "name" => "updated task name",
          "description" => "updated task description"
        })

      assert json_response(conn, 404)["errors"] != %{}

      updated_task = Repo.get(Task, task.id)
      assert updated_task.name == task.name
      assert updated_task.description == task.description
    end

    test "shouldn't allow update tasks with invalid params", %{conn: conn} do
      project = insert(:project)
      task = insert(:task, project: project)

      conn =
        put(conn, "api/v1/project/#{project.id}/task/#{task.id}", %{
          "name" => nil,
          "description" => "updated task description"
        })

      assert json_response(conn, 404)["errors"] != %{}

      updated_task = Repo.get(Task, task.id)
      assert updated_task.name == task.name
      assert updated_task.description == task.description
    end
  end

  describe "delete" do
    test "shouldn't allow delete tasks from projects from other users", %{conn: conn} do
      task = insert(:task)

      conn = delete(conn, "api/v1/project/#{task.project.id}/task/#{task.id}")

      assert json_response(conn, 404)["errors"] != %{}

      refute Task |> Repo.get(task.id) |> is_nil()
    end

    test "should allow delete tasks from user projects", %{conn: conn, user: user} do
      task = insert(:task, project: build(:project, owner: user))

      conn = delete(conn, "api/v1/project/#{task.project.id}/task/#{task.id}")

      assert response(conn, 204)

      assert Task |> Repo.get(task.id) |> is_nil()
    end
  end
end
