defmodule HTTPizza.Observers.HTTPObserver.Scheduler do
  require Logger

  use Oban.Worker, queue: :default, unique: [period: 60, fields: [:worker]]

  alias HTTPizza.Observers

  @impl Oban.Worker
  def perform(_job) do
    observers = HTTPizza.Observers.list_http_observers_past_scheduled_run()

    Enum.each(observers, fn %Observers.HTTPObserver{} = observer ->
      with {:ok, expr} <- Crontab.CronExpression.Parser.parse(observer.schedule),
           {:ok, naive_next_run} <- Crontab.Scheduler.get_next_run_date(expr),
           {:ok, next_run} <- DateTime.from_naive(naive_next_run, "Etc/UTC") do
        enqueue_worker_and_schedule_observer(observer, next_run)
      else
        _ ->
          Logger.error(
            "unable to determine next scheduled run for `HTTPObserver` with id='#{observer.id}'"
          )
      end
    end)

    :ok
  end

  @spec enqueue_worker_and_schedule_observer(%HTTPizza.Observers.HTTPObserver{}, DateTime.t()) ::
          :ok | :error
  @doc """
  Uses `Ecto.Multi` to insert an Oban job for an `HTTPObserverWorker` and to update the given observer
  to run at the given `DateTime`
  """
  def enqueue_worker_and_schedule_observer(
        %Observers.HTTPObserver{} = observer,
        %DateTime{} = next_run
      ) do
    result =
      Ecto.Multi.new()
      |> Oban.insert(:job, HTTPizza.HTTPObserverWorker.new(%{"id" => observer.id}))
      |> Ecto.Multi.update(
        :observer,
        Observers.change_http_observer(observer, %{"scheduled_at" => next_run})
      )
      |> HTTPizza.Repo.transaction()

    with {:ok, _} <- result do
      Logger.info("scheduled job for `HTTPObserver` with id='#{observer.id}'")
      :ok
    else
      _ ->
        Logger.error("unable to schedule job for `HTTPObserver` with id='#{observer.id}'")
        :error
    end
  end
end
