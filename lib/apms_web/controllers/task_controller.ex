defmodule ApmsWeb.TaskController do
  use ApmsWeb, :controller

  alias Apms.Tasks

  action_fallback ApmsWeb.FallbackController

  def index(conn, %{"project_id" => project_id}) do
    with project <- Tasks.get_project!(project_id),
         true <- Tasks.is_user_project?(project, conn.assigns.user.id),
         tasks <- Tasks.list_tasks(project_id) do
      conn
      |> render("index.json", tasks: tasks)
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> put_view(ApmsWeb.ErrorView)
        |> render(:"404")
    end
  end

  def create(conn, %{"project_id" => project_id, "name" => name, "description" => description}) do
    with project <- Tasks.get_project!(project_id),
         true <- Tasks.is_user_project?(project, conn.assigns.user.id),
         {:ok, task} <-
           Tasks.create_task(%{
             project_id: project_id,
             name: name,
             description: description
           }) do
      conn
      |> put_status(:created)
      |> render("show.json", task: task)
    else
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(ApmsWeb.ErrorView)
        |> render(:"422")
    end
  end

  def create(conn, _) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ApmsWeb.ErrorView)
    |> render(:"422")
  end

  def update(
        conn,
        %{
          "project_id" => project_id,
          "id" => id
        } = params
      ) do
    with project <- Tasks.get_project!(project_id),
         true <- Tasks.is_user_project?(project, conn.assigns.user.id),
         task <- Tasks.get_task!(id),
         params <-
           Enum.reduce(params, %{}, fn {key, val}, acc ->
             Map.put(acc, String.to_existing_atom(key), val)
           end),
         {:ok, task} <- Tasks.update_task(task, params) do
      conn
      |> render("show.json", task: task)
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> put_view(ApmsWeb.ErrorView)
        |> render(:"404")
    end
  end

  def update(conn, _) do
    conn
    |> put_status(:not_found)
    |> put_view(ApmsWeb.ErrorView)
    |> render(:"404")
  end

  def delete(conn, %{"project_id" => project_id, "id" => id}) do
    with project <- Tasks.get_project!(project_id),
         true <- Tasks.is_user_project?(project, conn.assigns.user.id),
         task <- Tasks.get_task!(id),
         {:ok, _} <- Tasks.delete_task(task) do
      send_resp(conn, :no_content, "")
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> put_view(ApmsWeb.ErrorView)
        |> render(:"404")
    end
  end

  def delete(conn, _) do
    conn
    |> put_status(:not_found)
    |> put_view(ApmsWeb.ErrorView)
    |> render(:"404")
  end
end
