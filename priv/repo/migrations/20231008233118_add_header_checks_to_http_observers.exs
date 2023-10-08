defmodule HTTPizza.Repo.Migrations.AddHeaderChecksToHTTPObservers do
  use Ecto.Migration

  def change do
    alter table(:http_observers) do
      add(:header_checks, {:array, :map})
    end
  end
end
