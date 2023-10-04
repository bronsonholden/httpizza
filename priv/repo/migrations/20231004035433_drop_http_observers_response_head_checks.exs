defmodule HTTPizza.Repo.Migrations.DropHttpObserversResponseHeadChecks do
  use Ecto.Migration

  def change do
    alter table(:http_observers) do
      remove(:response_head_checks)
    end
  end
end
