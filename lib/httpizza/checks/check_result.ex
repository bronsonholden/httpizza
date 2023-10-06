defmodule HTTPizza.Checks.CheckResult do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :status, Ecto.Enum, values: [:ok, :failed, :error]
    field :reason, :string
    field :kind, :string
  end

  @doc false
  def changeset(check_result, attrs) do
    check_result
    |> cast(attrs, [:status, :reason, :kind])
    |> validate_required([:status, :reason, :kind])
  end
end
