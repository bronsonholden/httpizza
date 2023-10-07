defmodule HTTPizza.Repo.Migrations.ReplaceHTTPObserverPath do
  use Ecto.Migration

  def up do
    alter table(:http_observers) do
      remove(:path)
      add(:path, :string, default: "")
    end
  end

  def down do
    alter table(:http_observers) do
      remove(:path)
      add(:path, {:array, :string})
    end
  end
end
