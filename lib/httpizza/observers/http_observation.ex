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
    field :reason, :string
    field :resolved, :boolean, default: false

    belongs_to :http_observer, HTTPizza.Observers.HTTPObserver

    embeds_many :check_results, HTTPizza.Checks.CheckResult

    timestamps()
  end

  @doc false
  def changeset(http_observation, %{check_results: check_results} = attrs) do
    http_observation
    |> changeset(Map.delete(attrs, :check_results))
    |> put_embed(:check_results, check_results)
  end

  @doc false
  def changeset(http_observation, attrs) do
    http_observation
    |> cast(attrs, [:status, :resolved, :reason, :started_at, :duration, :http_observer_id])
    |> validate_required(:http_observer_id)
    |> assoc_constraint(:http_observer)
  end
end
