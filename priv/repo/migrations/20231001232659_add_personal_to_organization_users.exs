defmodule HTTPizza.Repo.Migrations.AddPersonalToOrganizationUsers do
  use Ecto.Migration

  def change do
    alter table(:organization_user) do
      add(:personal, :boolean)
    end

    create unique_index(:organization_user, [:user_id, :personal])
  end
end
