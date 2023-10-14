defmodule HTTPizza.Checks.CheckResult do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :status, Ecto.Enum, values: [:ok, :failed, :error]
    field :reason, :string
    field :kind, :string
    embeds_one :header_check, HTTPizza.Checks.HeaderCheck
    embeds_one :status_check, HTTPizza.Checks.StatusCheck
  end

  @kinds [
    {"Elixir.HTTPizza.Checks.HeaderCheck", :header_check},
    {"Elixir.HTTPizza.Checks.StatusCheck", :status_check}
  ]

  @doc false
  def changeset(check_result, attrs) do
    check_result
    |> cast(attrs, [:status, :reason, :kind])
    |> cast_embed(:header_check)
    |> cast_embed(:status_check)
    |> validate_required([:status, :reason, :kind])
    |> validate_inclusion(:kind, Enum.map(@kinds, &elem(&1, 0)))
    |> validate_embedded_checks()
  end

  defp validate_embedded_checks(changeset) do
    if changed?(changeset, :kind) do
      validate_embedded_check_for_kind(changeset, changeset.changes.kind)
    else
      changeset
    end
  end

  defp validate_embedded_check_for_kind(changeset, kind) do
    field =
      Enum.find(@kinds, fn
        {^kind, _field} -> true
        _ -> false
      end)
      |> elem(1)

    validate_required(changeset, field)
  end
end
