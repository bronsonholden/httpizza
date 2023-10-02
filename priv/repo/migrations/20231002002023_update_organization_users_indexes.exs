defmodule HTTPizza.Repo.Migrations.UpdateOrganizationUsersConstraints do
  use Ecto.Migration

  def change do
    drop index(:organization_users, :organization_id,
           name: "organization_user_organization_id_index"
         )

    drop index(:organization_users, :user_id, name: "organization_user_user_id_index")

    drop unique_index(:organization_users, [:user_id, :personal],
           name: "organization_user_user_id_personal_index"
         )

    create unique_index(:organization_users, :organization_id)
    create unique_index(:organization_users, :user_id)
    create unique_index(:organization_users, [:user_id, :personal])
  end
end
