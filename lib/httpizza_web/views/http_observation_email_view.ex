defmodule HTTPizzaWeb.HTTPObservationEmailView do
  use Phoenix.View, root: "lib/httpizza_web/templates"
  use Phoenix.Component
  use HTTPizzaWeb, :verified_routes

  def links(assigns) do
    assigns =
      assigns
      |> assign(
        :observation_url,
        ~p"/dashboard/#{assigns.http_observation.http_observer.organization.slug}/http-observations/#{assigns.http_observation.id}"
      )
      |> assign(
        :observer_url,
        ~p"/dashboard/#{assigns.http_observation.http_observer.organization.slug}/http-observers/#{assigns.http_observation.http_observer.id}/edit"
      )

    ~H"""
    <p>
      Click <a href={@observation_url}>here</a> to view the observation,
      or <a href={@observer_url}>here</a> to view the observer configuration.
    </p>
    """
  end
end
