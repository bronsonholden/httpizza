defmodule HTTPizzaWeb.Cron.DeleteIncompletExpiredSubscriptions do
  use Oban.Worker, queue: :default, unique: [period: 60, fields: [:worker]]

  alias HTTPizza.Repo
  alias HTTPizza.Products.Subscription

  import Ecto.Query

  @impl Oban.Worker
  def perform(_job \\ %{})

  def perform(_job) do
    from(s in Subscription, where: s.status == :incomplete_expired)
    |> Repo.delete_all()
  end
end
