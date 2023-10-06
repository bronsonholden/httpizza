defmodule HTTPizza.Repo.Migrations.AddEmailRecipientsToHTTPObservers do
  use Ecto.Migration

  def change do
    alter table(:http_observers) do
      add(:email_recipients, {:array, :map}, default: [])
    end
  end
end
