defmodule HTTPizza.Repo.Migrations.AddStatusChecksToHttpObservers do
  use Ecto.Migration

  def change do
    alter table(:http_observers) do
      add(:status_checks, {:array, :map})
    end
  end
end
