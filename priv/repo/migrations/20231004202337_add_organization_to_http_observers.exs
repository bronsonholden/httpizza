defmodule HTTPizza.Repo.Migrations.AddOrganizationToHTTPObservers do
  use Ecto.Migration

  def change do
    alter table(:http_observers) do
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all),
        null: false
    end
  end
end
