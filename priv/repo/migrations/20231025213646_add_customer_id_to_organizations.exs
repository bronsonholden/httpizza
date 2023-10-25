defmodule HTTPizza.Repo.Migrations.AddCustomerIdToOrganizations do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add(:customer_id, :string)
    end
  end
end
