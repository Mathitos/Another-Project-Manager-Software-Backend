defmodule Apms.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  alias Apms.Tasks.Project

  @type t :: %__MODULE__{
          name: String.t(),
          description: String.t(),
          project_id: String.t(),
          project: Ecto.Association.t(Apms.Accounts.User.t())
        }

  schema "tasks" do
    field :description, :string
    field :name, :string

    belongs_to :project, Project, foreign_key: :project_id, references: :id

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:name, :description, :project_id])
    |> validate_required([:name, :project_id])
  end
end
