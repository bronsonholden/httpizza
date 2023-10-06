defmodule HTTPizza.Observers.HTTPObservation do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "http_observations" do
    field :status, Ecto.Enum, values: [:ok, :failed, :error]
    field :started_at, :utc_datetime
    field :duration, :integer

    belongs_to :http_observer, HTTPizza.Observers.HTTPObserver

    embeds_many :check_results, HTTPizza.Checks.CheckResult

    timestamps()
  end

  @doc false
  def changeset(http_observation, attrs) do
    http_observation
    |> cast(attrs, [:status, :started_at, :duration, :http_observer_id])
    |> cast_embed(:check_results)
    |> validate_required(:http_observer_id)
    |> assoc_constraint(:http_observer)
  end
end
