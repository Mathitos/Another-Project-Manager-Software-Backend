defmodule ApmsWeb.ProjectController do
  use ApmsWeb, :controller

  alias Apms.Tasks
  alias Apms.Tasks.Project

  action_fallback ApmsWeb.FallbackController

  def index(conn, _params) do
    user = conn.assigns.user

    projects = Tasks.list_projects(user.id)
    render(conn, "index.json", projects: projects)
  end

  def create(conn, %{"name" => name}) do
    with {:ok, %Project{} = project} <-
           Tasks.create_project(%{name: name, owner_id: conn.assigns.user.id}) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.project_path(conn, :show, project))
      |> render("show.json", project: project)
    end
  end

  def create(conn, _) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ApmsWeb.ErrorView)
    |> render(:"422")
  end

  def show(conn, %{"id" => id}) do
    with project <- Tasks.get_project!(id),
         true <- Tasks.is_user_project?(project, conn.assigns.user.id) do
      render(conn, "show.json", project: project)
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> put_view(ApmsWeb.ErrorView)
        |> render(:"404")
    end
  end

  def update(conn, %{"id" => id} = params) do
    with project <- Tasks.get_project!(id),
         true <- Tasks.is_user_project?(project, conn.assigns.user.id),
         {:ok, %Project{} = project} <- Tasks.update_project(project, params) do
      render(conn, "show.json", project: project)
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> put_view(ApmsWeb.ErrorView)
        |> render(:"404")
    end
  end

  def delete(conn, %{"id" => id}) do
    with project <- Tasks.get_project!(id),
         true <- Tasks.is_user_project?(project, conn.assigns.user.id),
         {:ok, %Project{}} <- Tasks.delete_project(project) do
      send_resp(conn, :no_content, "")
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> put_view(ApmsWeb.ErrorView)
        |> render(:"404")
    end
  end
end
