defmodule HTTPizza.Repo.Migrations.AddCheckResultsToHTTPObservations do
  use Ecto.Migration

  def change do
    alter table(:http_observations) do
      add(:check_results, {:array, :map}, default: [])
    end
  end
end
