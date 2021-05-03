defmodule ApmsWeb.ProjectControllerTest do
  use ApmsWeb.ConnCase

  alias Apms.Tasks.Project

  setup %{conn: conn} do
    user = insert(:user)

    conn =
      conn
      |> add_auth_header(user)
      |> put_req_header("accept", "application/json")

    {:ok, conn: conn, user: user}
  end

  describe "index" do
    test "lists all the user projects", %{conn: conn, user: user} do
      insert(:project)
      user_project = insert(:project, owner: user)
      conn = get(conn, Routes.project_path(conn, :index))

      assert json_response(conn, 200)["data"] == [
               %{"id" => user_project.id, "name" => user_project.name}
             ]
    end
  end

  describe "create project" do
    test "assign current user to created project", %{conn: conn, user: user} do
      conn = post(conn, Routes.project_path(conn, :create), %{"name" => "some name"})
      assert %{"id" => id} = json_response(conn, 201)["data"]

      assert user.id == Project |> Repo.get(id) |> Map.get(:owner_id)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.project_path(conn, :create), %{})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update project" do
    setup [:create_project]

    test "renders project when data is valid", %{conn: conn, user: user} do
      %{id: id} = user_project = insert(:project, owner: user)

      conn =
        put(conn, Routes.project_path(conn, :update, user_project), %{
          "name" => "some updated name"
        })

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.project_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "dont render project when user is not owner", %{
      conn: conn,
      project: %Project{id: id} = project
    } do
      conn =
        put(conn, Routes.project_path(conn, :update, project), %{
          "name" => "some updated name"
        })

      assert json_response(conn, 404)["errors"] != %{}

      refute Project |> Repo.get(id) |> Map.get(:name) == "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, project: project} do
      conn = put(conn, Routes.project_path(conn, :update, project), %{})
      assert json_response(conn, 404)["errors"] != %{}
    end
  end

  describe "delete project" do
    setup [:create_project]

    test "dont allow delete projects from other users", %{conn: conn, project: project} do
      conn = delete(conn, Routes.project_path(conn, :delete, project))
      assert json_response(conn, 404)["errors"] != %{}
    end

    test "allow delete orjects that belongs to the user", %{conn: conn, user: user} do
      user_project = insert(:project, owner: user)
      conn = delete(conn, Routes.project_path(conn, :delete, user_project))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.project_path(conn, :show, user_project))
      end
    end
  end

  describe "get" do
    test "renders project when data is valid", %{conn: conn, user: user} do
      %{name: name, id: id} = insert(:project, owner: user)

      conn = get(conn, Routes.project_path(conn, :show, id))

      assert %{
               "id" => _id,
               "name" => ^name
             } = json_response(conn, 200)["data"]
    end
  end

  defp create_project(_) do
    %{project: insert(:project, name: "some name")}
  end
end
