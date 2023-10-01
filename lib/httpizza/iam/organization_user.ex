defmodule HTTPizza.IAM.OrganizationUser do
  use Ecto.Schema

  alias HTTPizza.IAM

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organization_user" do
    belongs_to :organization, IAM.Organization
    belongs_to :user, IAM.User
    field :personal, :boolean

    timestamps()
  end

  @doc false
  def changeset(organization_user, attrs) do
    organization_user
    |> cast(attrs, [:organization_id, :user_id])
    |> validate_required([:organization_id, :user_id])
  end
end
