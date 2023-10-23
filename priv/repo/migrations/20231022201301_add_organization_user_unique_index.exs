defmodule HTTPizza.Repo.Migrations.AddOrganizationUserUniqueIndex do
  use Ecto.Migration

  def change do
    create unique_index(:organization_users, [:organization_id, :user_id])
  end
end
