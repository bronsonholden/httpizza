defmodule HTTPizzaWeb.HTTPObservationEmailView do
  use Phoenix.View, root: "lib/httpizza_web/templates"
  use Phoenix.Component
  use HTTPizzaWeb, :verified_routes

  alias HTTPizza.Observers.HTTPObserver

  def results(assigns) do
    assigns =
      assigns
      |> assign(:http_observer, assigns.http_observation.http_observer)
      |> assign(
        :observation_url,
        url(
          ~p"/dashboard/#{assigns.http_observation.http_observer.organization.slug}/http-observations/#{assigns.http_observation.id}"
        )
      )
      |> assign(
        :observer_url,
        url(
          ~p"/dashboard/#{assigns.http_observation.http_observer.organization.slug}/http-observers/#{assigns.http_observation.http_observer.id}/edit"
        )
      )

    ~H"""
    <h2>
      Observer:
      <a href={@observer_url}>
        <%= @http_observer.method |> to_string() |> String.upcase() %> <%= build_uri(@http_observer) %>
      </a>
    </h2>

    <p :for={check <- @http_observation.check_results}>
      <%= check.status %>: <%= check.reason %>
    </p>

    <p>
      Click <a href={@observation_url}>here</a> to view the observation in HTTPizza
    </p>
    """
  end

  # TODO: move to shared util module
  defp build_uri(%HTTPObserver{} = observer) do
    URI.new!(%URI{
      host: observer.hostname,
      port: observer.port,
      path: observer.path,
      scheme: if(observer.https, do: "https", else: "http")
    })
    |> URI.to_string()
  end
end
