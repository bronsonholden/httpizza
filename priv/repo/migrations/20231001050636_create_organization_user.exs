defmodule HTTPizza.Repo.Migrations.CreateOrganizationUser do
  use Ecto.Migration

  def change do
    create table(:organization_user, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :organization_id, references(:organizations, on_delete: :nothing, type: :binary_id),
        null: false

      add :user_id, references(:users, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:organization_user, [:organization_id])
    create index(:organization_user, [:user_id])
  end
end
