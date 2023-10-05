defmodule HTTPizza.Checks.HTTPStatusCheck do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "http_status_checks" do
    field :code, :string
    field :comparator, Ecto.Enum, values: [:is_exactly, :is_success, :is_redirect]

    timestamps()
  end

  @doc false
  def changeset(http_status_check, attrs) do
    http_status_check
    |> cast(attrs, [:comparator, :code])
    |> validate_required([:comparator])
    |> maybe_validate_code_required(http_status_check)
  end

  defp maybe_validate_code_required(changeset, http_status_check) do
    if http_status_check.comparator == :is_exactly or
         get_change(changeset, :comparator) == :is_exactly do
      validate_required(changeset, :code)
    else
      changeset
    end
  end
end
