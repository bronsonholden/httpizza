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
    field :method, Ecto.Enum, values: [:get]
    field :scheduled_at, :utc_datetime

    belongs_to :organization, HTTPizza.IAM.Organization
    has_many :http_head_checks, HTTPizza.Checks.HTTPHeadCheck

    timestamps()
  end

  @doc false
  def changeset(
        http_observer,
        %{organization: %HTTPizza.IAM.Organization{} = organization} = attrs
      ) do
    http_observer
    |> changeset(Map.delete(attrs, :organization))
    |> put_assoc(:organization, organization)
  end

  @doc false
  def changeset(http_observer, attrs) do
    http_observer
    |> cast(attrs, [:schedule, :https, :hostname, :port, :path, :method, :organization_id])
    |> validate_required([
      :schedule,
      :https,
      :hostname,
      :port,
      :path,
      :method
    ])
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
