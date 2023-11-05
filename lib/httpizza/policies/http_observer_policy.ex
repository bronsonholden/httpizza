defmodule HTTPizza.HTTPObserverPolicy do
  alias HTTPizza.Products

  @default_http_observer_limit 5
  @default_min_schedule_interval 60

  def authorize(action, _user, _org, http_observer \\ nil)

  def authorize("create", _user, organization, nil) do
    existing_observers = HTTPizza.Observers.count_organization_http_observers(organization.id)
    limit = http_observer_limit(organization)

    if is_nil(limit) or existing_observers < limit do
      :ok
    else
      {:unauthorized, "You have reached your HTTP observer limit of #{limit}."}
    end
  end

  def authorize("schedule", _user, _organization, nil), do: :ok

  def authorize("schedule", _user, organization, schedule) do
    interval = get_schedule_interval(schedule)
    allowed_interval = min_schedule_interval(organization)

    if interval >= allowed_interval do
      :ok
    else
      {:unauthorized,
       "must be at most once per #{allowed_interval} minutes—subscribe for more frequent runs"}
    end
  end

  defp min_schedule_interval(organization) do
    case Products.get_organization_subscription!(organization.id) do
      nil -> @default_min_schedule_interval
      subscription -> subscription.min_schedule_interval
    end
  end

  defp http_observer_limit(organization) do
    case Products.get_organization_subscription!(organization.id) do
      nil -> @default_http_observer_limit
      subscription -> subscription.http_observer_limit
    end
  end

  defp get_schedule_interval(cron) do
    with {:ok, expr} <- Crontab.CronExpression.Parser.parse(cron),
         stream <- Crontab.Scheduler.get_next_run_dates(expr),
         [pre, post] <- Enum.take(stream, 2) do
      Timex.diff(post, pre, :minute)
    else
      _ -> nil
    end
  end
end
