defmodule HTTPizza.Observers.HTTPObservation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "http_observations" do
    field :status, Ecto.Enum, values: [:ok, :failed, :error]
    field :started_at, :utc_datetime
    field :duration, :integer

    belongs_to :http_observer, HTTPizza.Observers.HTTPObserver

    timestamps()
  end

  @doc false
  def changeset(http_observation, attrs) do
    http_observation
    |> cast(attrs, [:status, :started_at, :duration, :http_observer_id])
    |> validate_required(:http_observer_id)
    |> assoc_constraint(:http_observer)
  end
end
