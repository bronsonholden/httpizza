defmodule HTTPizzaWeb.EditHTTPObserverLive do
  use HTTPizzaWeb, :live_view

  alias HTTPizza.Observers

  import HTTPizzaWeb.Templates

  on_mount {HTTPizzaWeb.UserAuth, :ensure_authenticated}
  on_mount {HTTPizzaWeb.Organization, :ensure_organization_selected}

  @impl true
  def handle_params(%{"id" => id}, uri, socket) do
    # TODO: verify in org
    http_observer = Observers.get_http_observer!(id)

    socket =
      socket
      |> assign(:http_observer, http_observer)
      |> assign(:current_uri, uri)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.dashboard
      current_uri={@current_uri}
      organizations={@current_user.organizations}
      personal_organization={@current_user.personal_organization}
      current_organization={@current_organization}
      slug={@current_organization_slug}
    >
      <%= live_render(@socket, HTTPizzaWeb.HTTPObserverFormLive,
        id: "new-http-observer-form",
        session: %{
          "slug" => @current_organization_slug,
          "action" => :edit,
          "http_observer" => @http_observer
        }
      ) %>
    </.dashboard>
    """
  end
end
