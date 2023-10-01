defmodule HTTPizza.Repo.Migrations.RenameOrganizationUserTable do
  use Ecto.Migration

  def up do
    drop constraint(:organization_user, "organization_user_pkey")
    drop constraint(:organization_user, "organization_user_organization_id_fkey")
    drop constraint(:organization_user, "organization_user_user_id_fkey")

    rename table(:organization_user), to: table(:organization_users)

    alter table(:organization_users) do
      modify :id, :binary_id, primary_key: true

      modify :organization_id, references(:organizations, on_delete: :nothing, type: :binary_id),
        null: false

      modify :user_id, references(:users, on_delete: :nothing, type: :binary_id), null: false
    end
  end

  def down do
    drop constraint(:organization_users, "organization_users_pkey")
    drop constraint(:organization_users, "organization_users_organization_id_fkey")
    drop constraint(:organization_users, "organization_users_user_id_fkey")

    rename table(:organization_users), to: table(:organization_user)

    alter table(:organization_user) do
      modify :id, :binary_id, primary_key: true

      modify :organization_id, references(:organizations, on_delete: :nothing, type: :binary_id),
        null: false

      modify :user_id, references(:users, on_delete: :nothing, type: :binary_id), null: false
    end
  end
end
