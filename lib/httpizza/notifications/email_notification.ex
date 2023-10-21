defmodule HTTPizza.Notifications.EmailNotification do
  @moduledoc """
  Enqueued in the transaction that inserts HTTP observations into the database.
  Processing this job will determine what, if any emails, should be sent. A
  follow-up job is inserted for every email that has to be sent out.
  """

  require Logger

  use Oban.Worker, queue: :notifiers, unique: [period: 60, fields: [:args]]
  use HTTPizzaWeb, :verified_routes

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"http_observation_id" => http_observation_id}
      }) do
    http_observation =
      HTTPizza.Observers.get_http_observation!(http_observation_id)
      |> HTTPizza.Repo.preload(http_observer: :organization)

    http_observer = http_observation.http_observer

    multi =
      Enum.reduce(http_observer.email_recipients, Ecto.Multi.new(), fn email_recipient, multi ->
        if (email_recipient.ok and http_observation.status == :ok) or
             (email_recipient.failed and http_observation.status == :failed) or
             (email_recipient.error and http_observation.status == :error) do
          Oban.insert(
            multi,
            :job,
            HTTPizza.Notifications.EmailNotification.Job.new(%{
              "recipient" => email_recipient.email,
              "http_observation_id" => http_observation.id
            })
          )
        else
          multi
        end
      end)

    HTTPizza.Repo.transaction(multi)
  end
end
