defmodule HTTPizza.Repo.Migrations.AddMethodToHttpObservers do
  use Ecto.Migration

  def change do
    alter table(:http_observers) do
      add(:method, :string, null: false)
    end
  end
end
