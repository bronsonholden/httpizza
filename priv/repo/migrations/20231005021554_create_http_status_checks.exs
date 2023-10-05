defmodule HTTPizza.Repo.Migrations.CreateHTTPStatusChecks do
  use Ecto.Migration

  def change do
    create table(:http_status_checks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :comparator, :string, null: false
      add :code, :string

      timestamps()
    end
  end
end
