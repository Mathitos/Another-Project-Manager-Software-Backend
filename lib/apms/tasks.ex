defmodule Apms.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias Apms.Repo

  alias Apms.Tasks.{Project, Task}
  alias Ecto.Multi

  @doc """
  Returns the list of projects that belong to the user.

  ## Examples

      iex> list_projects(user_id)
      [%Project{}, ...]

  """
  def list_projects(user_id) do
    Project
    |> where(owner_id: ^user_id)
    |> Repo.all()
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id), do: Repo.get!(Project, id)

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end

  @doc """
  Return a boolean asserting if the project belong to user

  ## Examples

      iex> is_user_project?(project, user_id)
      true

  """
  def is_user_project?(project, user_id), do: project.owner_id == user_id

  @doc """
  Returns the list of tasks for given project.

  ## Examples

      iex> list_tasks(project_id)
      [%Task{}, ...]

  """
  def list_tasks(project_id) do
    Task
    |> where(project_id: ^project_id)
    |> order_by(asc: :order)
    |> Repo.all()
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(%{project_id: project_id} = attrs) when not is_nil(project_id) do
    attrs = Map.put(attrs, :order, get_last_order(project_id) + 1)

    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def create_task(_), do: {:error, %Ecto.Changeset{}}

  @doc """
  Updates a task. Also updated related tasks orders in case tha task order is updating.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%Task{} = task, %{order: new_order} = attrs) do
    max_order = get_last_order(task.project_id)

    case task.order do
      current_order when current_order == new_order ->
        update_task_without_order(task, attrs)

      current_order when new_order < 1 and current_order == 1 ->
        update_task_without_order(task, Map.put(attrs, :order, 1))

      current_order when new_order > max_order and current_order == max_order ->
        update_task_without_order(task, Map.put(attrs, :order, max_order))

      _ when new_order > max_order ->
        update_task_with_order(task, Map.put(attrs, :order, max_order))

      _ when new_order < 1 ->
        update_task_with_order(task, Map.put(attrs, :order, 1))

      _ ->
        update_task_with_order(task, attrs)
    end
  end

  def update_task(%Task{} = task, attrs), do: update_task_without_order(task, attrs)

  defp update_task_with_order(%Task{} = task, %{order: new_order} = attrs)
       when new_order > task.order do
    Multi.new()
    |> Multi.update_all(
      :updated_tasks,
      Task
      |> where([t], t.order > ^task.order)
      |> where([t], t.order <= ^new_order)
      |> update([t], inc: [order: -1]),
      []
    )
    |> Multi.update(:task, Task.changeset(task, attrs))
    |> Repo.transaction()
    |> case do
      {:ok, %{task: task}} -> {:ok, task}
      _ -> {:error, %Ecto.Changeset{}}
    end
  end

  defp update_task_with_order(%Task{} = task, %{order: new_order} = attrs)
       when new_order < task.order do
    Multi.new()
    |> Multi.update_all(
      :updated_tasks,
      Task
      |> where([t], t.order < ^task.order)
      |> where([t], t.order >= ^new_order)
      |> update([t], inc: [order: +1]),
      []
    )
    |> Multi.update(:task, Task.changeset(task, attrs))
    |> Repo.transaction()
    |> case do
      {:ok, %{task: task}} -> {:ok, task}
      _ -> {:error, %Ecto.Changeset{}}
    end
  end

  def update_task_without_order(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  defp get_last_order(project_id) do
    Task
    |> where(project_id: ^project_id)
    |> order_by(desc: :order)
    |> limit(1)
    |> Repo.one()
    |> case do
      nil -> 0
      task -> task.order
    end
  end
end
