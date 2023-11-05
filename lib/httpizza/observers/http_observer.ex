defmodule HTTPizza.Observers.HTTPObserver do
  require Logger

  use Ecto.Schema

  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "http_observers" do
    field :https, :boolean, default: false
    field :port, :integer
    field :path, :string
    field :hostname, :string
    field :schedule, :string
    field :method, Ecto.Enum, values: [:get]
    field :scheduled_at, :utc_datetime

    belongs_to :organization, HTTPizza.IAM.Organization
    has_many :http_observations, HTTPizza.Observers.HTTPObservation

    embeds_many :email_recipients, HTTPizza.Notifications.EmailRecipient, on_replace: :delete
    embeds_many :header_checks, HTTPizza.Checks.HeaderCheck, on_replace: :delete
    embeds_many :status_checks, HTTPizza.Checks.StatusCheck, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(
        http_observer,
        %{organization: %HTTPizza.IAM.Organization{} = organization} = attrs
      ) do
    http_observer
    |> cast(%{}, [])
    |> put_assoc(:organization, organization)
    |> changeset(Map.delete(attrs, :organization))
  end

  @doc false
  def changeset(http_observer, attrs) do
    http_observer
    |> cast(attrs, [
      :schedule,
      :scheduled_at,
      :https,
      :hostname,
      :port,
      :path,
      :method,
      :organization_id
    ])
    |> cast_embed(:header_checks)
    |> cast_embed(:status_checks)
    |> cast_embed(:email_recipients)
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
    |> maybe_put_scheduled_at()
  end

  def maybe_put_scheduled_at(changeset) do
    if Ecto.Changeset.changed?(changeset, :schedule) do
      schedule = Ecto.Changeset.get_change(changeset, :schedule)

      with {:ok, expr} <- Crontab.CronExpression.Parser.parse(schedule),
           {:ok, naive_next_run} <- Crontab.Scheduler.get_next_run_date(expr),
           {:ok, next_run} <- DateTime.from_naive(naive_next_run, "Etc/UTC") do
        Ecto.Changeset.put_change(changeset, :scheduled_at, next_run)
      else
        _ -> changeset
      end
    else
      changeset
    end
  end
end
