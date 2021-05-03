defmodule Apms.Tasks.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          name: String.t(),
          owner_id: String.t(),
          owner: Ecto.Association.t(Apms.Accounts.User.t())
        }

  schema "projects" do
    field :name, :string
    belongs_to :owner, Apms.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :owner_id])
    |> validate_required([:name, :owner_id])
  end
end
