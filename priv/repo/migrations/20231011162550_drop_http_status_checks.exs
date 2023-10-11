defmodule HTTPizza.Repo.Migrations.DropHttpStatusChecks do
  use Ecto.Migration

  def change do
    drop table(:http_status_checks)
  end
end
