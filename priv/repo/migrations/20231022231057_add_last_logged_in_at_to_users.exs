defmodule HTTPizza.Repo.Migrations.AddLastLoggedInAtToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:last_logged_in_at, :utc_datetime)
    end
  end
end
