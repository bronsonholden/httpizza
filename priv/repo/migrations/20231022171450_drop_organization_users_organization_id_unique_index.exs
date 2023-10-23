defmodule HTTPizza.Repo.Migrations.DropOrganizationUsersOrganizationIdUniqueIndex do
  use Ecto.Migration

  def change do
    drop unique_index(:organization_users, :organization_id)
  end
end
