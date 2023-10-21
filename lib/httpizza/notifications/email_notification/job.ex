defmodule HTTPizza.Notifications.EmailNotification.Job do
  require Logger

  use Oban.Worker, queue: :notifiers, unique: [period: 60, fields: [:worker]]
  use HTTPizzaWeb, :verified_routes

  alias HTTPizza.Mailer

  import Swoosh.Email

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"recipient" => recipient, "subject" => subject, "body" => body}
      }) do
    email =
      new()
      |> to(recipient)
      |> from({"HTTPizza", "noreply@htt.pizza"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      :ok
    end
  end
end
