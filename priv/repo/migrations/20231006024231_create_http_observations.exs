defmodule HTTPizza.Repo.Migrations.CreateHttpObservations do
  use Ecto.Migration

  @timestamps_opts [type: :utc_datetime]

  def change do
    create table(:http_observations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string
      add :started_at, :utc_datetime
      add :duration, :integer
      add :http_observer_id, references(:http_observers, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:http_observations, [:http_observer_id])
  end
end
