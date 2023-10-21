defmodule HTTPizza.Notifications.EmailNotification.Job do
  require Logger

  use Oban.Worker, queue: :notifiers, unique: [period: 60, fields: [:args]]
  use HTTPizzaWeb, :verified_routes

  alias HTTPizza.Mailer

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"recipient" => recipient, "http_observation_id" => http_observation_id}
      }) do
    http_observation =
      http_observation_id
      |> HTTPizza.Observers.get_http_observation!()
      |> HTTPizza.Repo.preload(http_observer: :organization)

    email = HTTPizzaWeb.HTTPObservationEmail.report(recipient, http_observation)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      :ok
    end
  end
end
