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
    has_many :http_head_checks, HTTPizza.Checks.HTTPHeadCheck
    has_many :http_observations, HTTPizza.Observers.HTTPObservation

    embeds_many :email_recipients, HTTPizza.Notifications.EmailRecipient
    embeds_many :header_checks, HTTPizza.Checks.HeaderCheck, on_replace: :delete

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
    |> cast_assoc(:http_head_checks)
    |> cast_embed(:header_checks)
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

  @doc """
  Migrate associated `http_head_checks` into embedded `header_checks`
  """
  def migrate_header_check() do
    observers =
      HTTPizza.Observers.list_http_observers() |> HTTPizza.Repo.preload(:http_head_checks)

    results =
      Enum.map(observers, fn %{id: id} = observer ->
        with {:ok, _} <-
               HTTPizza.Observers.update_http_observer(observer, %{
                 path:
                   if(not is_nil(observer.path) and observer.path != "",
                     do: observer.path,
                     else: "/"
                   ),
                 header_checks:
                   Enum.map(observer.http_head_checks, fn http_head_check ->
                     Map.take(http_head_check, [:header, :value, :comparator, :case_sensitive])
                   end)
               }) do
          Logger.debug(
            "migrated `http_head_checks` => `header_checks` for `HTTPObserver` with id='#{id}'"
          )

          :ok
        else
          _ ->
            Logger.error("unable to migrate `HTTPObserver` with id='#{id}'")
            :error
        end
      end)

    ok = Enum.filter(results, fn r -> r == :ok end) |> Enum.count()
    failed = Enum.filter(results, fn r -> r == :error end) |> Enum.count()

    Logger.info(
      "finished migrating `http_head_checks` => `header_checks`: #{ok} ok, #{failed} failed"
    )
  end
end
