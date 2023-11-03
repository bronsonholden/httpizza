defmodule HTTPizza.Repo.Migrations.AddBillingEmailToOrganizations do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add(:billing_email, :string)
    end
  end
end
