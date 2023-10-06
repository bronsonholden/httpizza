defmodule HTTPizza.Repo.Migrations.AddScheduledAtToHTTPObservers do
  use Ecto.Migration

  def change do
    alter table(:http_observers) do
      add(:scheduled_at, :utc_datetime)
    end
  end
end
