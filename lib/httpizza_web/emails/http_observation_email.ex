defmodule HTTPizzaWeb.HTTPObservationEmail do
  use HTTPizzaWeb, :verified_routes

  use Phoenix.Swoosh,
    view: HTTPizzaWeb.HTTPObservationEmailView,
    layout: {HTTPizzaWeb.LayoutsView, :email}

  alias HTTPizza.Observers.HTTPObservation

  def report(recipient, %HTTPObservation{} = http_observation) do
    new()
    |> from({"HTTPizza", "noreply@htt.pizza"})
    |> to(recipient)
    |> subject_for(http_observation)
    |> body_for(http_observation)
  end

  defp subject_for(email, %HTTPObservation{status: :ok}) do
    subject(email, "HTTP observation successful")
  end

  defp subject_for(email, %HTTPObservation{status: :failed}) do
    subject(email, "HTTP observation failure")
  end

  defp subject_for(email, %HTTPObservation{status: :error}) do
    subject(email, "HTTP observation error")
  end

  defp body_for(email, %HTTPObservation{} = http_observation) do
    render_body(email, "#{to_string(http_observation.status)}.html", %{
      http_observation: http_observation
    })
  end
end
