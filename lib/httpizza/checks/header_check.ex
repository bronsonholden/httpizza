defmodule HTTPizza.Checks.HeaderCheck do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :value, :string
    field :header, :string
    field :case_sensitive, :boolean, default: true

    field :comparator, Ecto.Enum,
      values: [:contains, :equal_to, :starts_with, :ends_with, :does_not_contain, :not_equal_to]
  end

  @doc false
  def changeset(header_check, attrs) do
    header_check
    |> cast(attrs, [:value, :header, :comparator, :case_sensitive])
    |> validate_required([:value, :header, :comparator, :case_sensitive])
  end
end
