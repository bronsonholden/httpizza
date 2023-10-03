defmodule HTTPizza.Repo.Migrations.CreateHttpObservers do
  use Ecto.Migration

  def change do
    create table(:http_observers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :schedule, :string
      add :https, :boolean, default: false, null: false
      add :hostname, :string
      add :port, :integer
      add :path, {:array, :string}
      add :response_head_checks, {:array, :string}

      timestamps()
    end
  end
end
