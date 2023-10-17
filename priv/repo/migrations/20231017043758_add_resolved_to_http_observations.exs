defmodule HTTPizza.Repo.Migrations.AddResolvedToHttpObservations do
  use Ecto.Migration

  def change do
    alter table(:http_observations) do
      add(:resolved, :boolean)
    end
  end
end
