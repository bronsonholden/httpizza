defmodule HTTPizza.IAM.Organization do
  use Ecto.Schema

  alias HTTPizza.Products
  alias HTTPizza.IAM.OrganizationUser

  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organizations" do
    field :name, :string
    field :slug, :string
    field :customer_id, :string
    field :billing_email, :string

    has_many :subscriptions, Products.Subscription
    has_many :organization_users, OrganizationUser
    has_many :users, through: [:organization_users, :user]

    timestamps()
  end

  def changeset(organization, %{"users" => users} = attrs) do
    changeset(organization, Map.delete(attrs, "users"))
    |> put_assoc(
      :organization_users,
      Enum.map(users, fn user ->
        %{user_id: user.id}
      end)
    )
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :slug, :customer_id, :billing_email])
    |> unique_constraint(:slug)
    |> validate_required(:slug)
    |> validate_length(:slug, min: 2)
    |> validate_format(:slug, ~r/^([a-z0-9]+-)*[a-z0-9]+$/)
    |> validate_exclusion(:slug, ~w(personal))
  end
end
