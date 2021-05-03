defmodule Apms.Tasks.Project do
  use Ecto.Schema
  import Ecto.Changeset

  alias Apms.Tasks.Task
  alias Apms.Accounts.User

  @type t :: %__MODULE__{
          name: String.t(),
          owner_id: String.t(),
          owner: Ecto.Association.t(User.t()),
          tasks: list(Ecto.Association.t(Task.t()))
        }

  schema "projects" do
    field :name, :string
    belongs_to :owner, User
    has_many :tasks, Task, foreign_key: :project_id, references: :id

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :owner_id])
    |> validate_required([:name, :owner_id])
  end
end
