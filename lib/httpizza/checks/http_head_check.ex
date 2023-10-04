defmodule HTTPizza.Checks.HTTPHeadCheck do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "http_head_checks" do
    field :value, :string
    field :header, :string

    field :comparator, Ecto.Enum,
      values: [:contains, :equal_to, :starts_with, :ends_with, :does_not_contain, :not_equal_to]

    field :http_observer_id, :binary_id
    field :case_sensitive, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(http_head_check, attrs) do
    http_head_check
    |> cast(attrs, [:header, :value, :comparator, :case_sensitive])
    |> validate_required([:header, :value, :comparator, :case_sensitive])
  end
end
