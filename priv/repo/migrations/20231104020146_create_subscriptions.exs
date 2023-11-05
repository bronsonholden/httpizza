defmodule HTTPizza.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:organization_id, references(:organizations, on_delete: :nothing, type: :binary_id))
      add(:subscription_id, :string)
      add(:status, :string)
      add(:live, :boolean, default: false)
      add(:current_period_start, :utc_datetime)
      add(:current_period_end, :utc_datetime)

      add(:http_observer_limit, :integer)
      add(:team_member_limit, :integer)
      add(:min_schedule_interval, :integer)
      add(:run_on_demand, :boolean)

      timestamps()
    end

    create index(:subscriptions, [:organization_id])
  end
end
