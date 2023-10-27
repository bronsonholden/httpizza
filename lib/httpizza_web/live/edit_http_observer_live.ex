defmodule HTTPizzaWeb.EditHTTPObserverLive do
  use HTTPizzaWeb, :live_view

  alias HTTPizza.Observers

  import HTTPizzaWeb.Templates

  on_mount {HTTPizzaWeb.UserAuth, :ensure_authenticated}
  on_mount {HTTPizzaWeb.Organization, :ensure_organization_selected}

  @impl true
  def handle_params(%{"id" => id}, uri, socket) do
    Observers.get_organization_observer(socket.assigns.current_organization.id, id)
    |> case do
      nil ->
        {:noreply,
         push_navigate(socket, to: ~p"/dashboard/#{socket.assigns.current_organization_slug}")}

      http_observer ->
        socket =
          socket
          |> assign(:http_observer, http_observer)
          |> assign(:current_uri, uri)

        {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.dashboard
      current_uri={@current_uri}
      organizations_with_status_counts={
        HTTPizza.Status.get_organizations_with_status_counts(@current_user)
      }
      personal_organization={@current_user.personal_organization}
      current_organization={@current_organization}
      slug={@current_organization_slug}
    >
      <div class="flex justify-between">
        <.link
          navigate={~p"/dashboard/#{@current_organization_slug}"}
          class="flex items-center font-medium text-sm text-stone-500 hover:text-black rounded"
        >
          <.icon name="hero-chevron-left scale-[65%]" /> Back
        </.link>
        <button
          phx-click="delete_http_observer"
          class="font-medium text-sm px-3 py-1 bg-red-500 hover:bg-red-600 text-white rounded"
        >
          Delete
        </button>
      </div>
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

  @impl true
  def handle_event("delete_http_observer", _params, socket) do
    HTTPizza.Observers.delete_http_observer(socket.assigns.http_observer)

    socket =
      socket
      |> put_flash(:info, "HTTP observer deleted")
      |> push_navigate(to: ~p"/dashboard/#{socket.assigns.current_organization_slug}")

    {:noreply, socket}
  end
end
