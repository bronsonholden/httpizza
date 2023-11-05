defmodule HTTPizza.Products.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "subscriptions" do
    field :subscription_id, :string

    field :status, Ecto.Enum,
      values: [:incomplete, :incomplete_expired, :active, :canceled, :unpaid]

    field :live, :boolean, default: false
    field :current_period_start, :utc_datetime
    field :current_period_end, :utc_datetime
    field :http_observer_limit, :integer, default: 5
    field :team_member_limit, :integer, default: 2
    field :min_schedule_interval, :integer, default: 60
    field :run_on_demand, :boolean, default: false

    belongs_to :organization, HTTPizza.IAM.Organization

    timestamps()
  end

  @doc false
  def changeset(
        subscription,
        %{organization: %HTTPizza.IAM.Organization{} = organization} = attrs
      ) do
    subscription
    |> changeset(Map.delete(attrs, :organization))
    |> put_assoc(:organization, organization)
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [
      :subscription_id,
      :status,
      :live,
      :current_period_start,
      :current_period_end,
      :http_observer_limit,
      :team_member_limit,
      :min_schedule_interval,
      :run_on_demand
    ])
    |> validate_required([:status])
  end
end
