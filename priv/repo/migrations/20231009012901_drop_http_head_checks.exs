defmodule HTTPizza.Repo.Migrations.DropHttpHeadChecks do
  use Ecto.Migration

  def change do
    drop table(:http_head_checks)
  end
end
