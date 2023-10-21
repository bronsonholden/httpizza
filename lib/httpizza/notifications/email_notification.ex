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
    organization = http_observer.organization

    subject =
      case http_observation.status do
        :ok -> "HTTP observer success"
        :failed -> "HTTP observer failure"
        :error -> "HTTP observer error"
      end

    http_observation_a =
      "<a href=\"#{~p"/dashboard/#{organization.slug}/http-observations/#{http_observation.id}"}\">here</a>"

    http_observer_a =
      "<a href=\"#{~p"/dashboard/#{organization.slug}/http-observers/#{http_observer.id}/edit"}\">here</a>"

    links =
      "Click #{http_observation_a} to review the observation, or #{http_observer_a} to view the observer configuration."

    body =
      case http_observation.status do
        :ok ->
          """
          An HTTP observation for your #{organization.name} organization was successful.

          #{links}

          You are receiving this notification because the observer is configured to notify this
          address on successful observations.
          """

        :error ->
          """
          An HTTP observation for your #{organization.name} organization experienced an error.
          This could be an outage with your service provider, or maybe something wrong with
          HTTPizza. We recommend you verify your observer configuration below, and manually
          verify your site.

          #{links}

          You are receiving this notification because the observer is configured to notify this
          address on unexpected errors.
          """

        :failed ->
          """
          An HTTP observer for your #{organization.name} organization has failed.

          #{links}

          You are receiving this notification because the observer is configured to notify this
          address on failed observations.
          """
      end

    multi =
      Enum.reduce(http_observer.email_recipients, Ecto.Multi.new(), fn email_recipient, multi ->
        if (email_recipient.ok and http_observation.status == :ok) or
             (email_recipient.failed and http_observation.status == :failed) or
             (email_recipient.error and http_observation.status == :error) do
          Logger.info("inserting notification job")

          Oban.insert(
            multi,
            :job,
            HTTPizza.Notifications.EmailNotification.Job.new(%{
              "recipient" => email_recipient.email,
              "subject" => subject,
              "body" => body
            })
          )
        else
          multi
        end
      end)

    HTTPizza.Repo.transaction(multi)
  end
end
