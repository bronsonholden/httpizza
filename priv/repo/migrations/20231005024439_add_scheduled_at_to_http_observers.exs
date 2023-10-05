defmodule HTTPizza.Repo.Migrations.AddScheduledAtToHttpObservers do
  use Ecto.Migration

  def change do
    alter table(:http_observers) do
      add(:scheduled_at, :utc_datetime)
    end
  end
end
