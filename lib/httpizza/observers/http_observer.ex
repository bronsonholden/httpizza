defmodule HTTPizza.Observers.HTTPObserver do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "http_observers" do
    field :https, :boolean, default: false
    field :port, :integer
    field :path, {:array, :string}
    field :hostname, :string
    field :schedule, :string
    field :response_head_checks, {:array, :string}

    timestamps()
  end

  @doc false
  def changeset(http_observer, attrs) do
    http_observer
    |> cast(attrs, [:schedule, :https, :hostname, :port, :path, :response_head_checks])
    |> validate_required([:schedule, :https, :hostname, :port, :path, :response_head_checks])
    |> validate_inclusion(:schedule, [
      # every minute
      "* * * * *",
      # every 5 minutes
      "*/5 * * * *",
      # every 10 minutes
      "*/10 * * * *",
      # every 15 minutes
      "*/15 * * * *",
      # every 30 minutes
      "*/30 * * * *",
      # every hour
      "0 * * * *",
      # every day
      "0 0 * * *"
    ])
  end
end
