defmodule HTTPizza.IAM.Organization do
  use Ecto.Schema

  alias HTTPizza.IAM.OrganizationUser

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organizations" do
    field :name, :string
    field :slug, :string

    has_many :organization_users, OrganizationUser
    has_many :users, through: [:organization_users, :user]

    timestamps()
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :slug])
    |> validate_required([:slug])
    |> validate_length(:slug, min: 2)
    |> validate_format(:slug, ~r/^([a-z0-9]+-)*[a-z0-9]+$/)
    |> validate_exclusion(:slug, ~w(personal))
  end
end
