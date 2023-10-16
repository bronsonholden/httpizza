defmodule HTTPizza.Repo.Migrations.UpdateOrganizationUsersOrganizationIdReference do
  use Ecto.Migration

  def up do
    drop constraint(:organization_users, "organization_users_organization_id_fkey")

    alter table(:organization_users) do
      modify :organization_id,
             references(:organizations, on_delete: :delete_all, type: :binary_id),
             null: false
    end
  end

  def down do
    drop constraint(:organization_users, "organization_users_organization_id_fkey")

    alter table(:organization_users) do
      modify :organization_id,
             references(:organizations, on_delete: :nothing, type: :binary_id),
             null: false
    end
  end
end
