defmodule HTTPizza.Repo.Migrations.AddReasonToHttpObservations do
  use Ecto.Migration

  def change do
    alter table(:http_observations) do
      add(:reason, :string)
    end
  end
end
