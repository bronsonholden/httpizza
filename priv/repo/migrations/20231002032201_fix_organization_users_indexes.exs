defmodule HTTPizza.Repo.Migrations.FixOrganizationUsersIndexes do
  use Ecto.Migration

  def change do
    drop unique_index(:organization_users, :user_id)
    drop unique_index(:organization_users, [:user_id, :personal])

    create index(:organization_users, :user_id)
    create index(:organization_users, [:user_id, :personal])
  end
end
