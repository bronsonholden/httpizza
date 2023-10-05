defmodule HTTPizza.Repo.Migrations.CreateHTTPHeadChecks do
  use Ecto.Migration

  def change do
    create table(:http_head_checks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :header, :citext
      add :value, :string
      add :comparator, :string
      add :case_sensitive, :boolean, null: false, default: true
      add :http_observer_id, references(:http_observers, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:http_head_checks, [:http_observer_id])
  end
end
