defmodule HTTPizza.Repo.Migrations.AddMethodToHTTPObservers do
  use Ecto.Migration

  def change do
    alter table(:http_observers) do
      add(:method, :string, null: false)
    end
  end
end
