defmodule HTTPizza.Checks.StatusCheck do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :code, :string
    field :comparator, Ecto.Enum, values: [:equal_to, :is_success, :is_redirect]
  end

  @doc false
  def changeset(http_status_check, attrs) do
    http_status_check
    |> cast(attrs, [:comparator, :code])
    |> validate_required([:comparator])
    |> maybe_validate_code_required(http_status_check)
  end

  defp maybe_validate_code_required(changeset, http_status_check) do
    if http_status_check.comparator == :equal_to or
         get_change(changeset, :comparator) == :equal_to do
      validate_required(changeset, :code)
    else
      changeset
    end
  end
end
