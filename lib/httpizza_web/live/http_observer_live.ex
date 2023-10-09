defmodule HTTPizzaWeb.HTTPObserverLive do
  use HTTPizzaWeb, :live_view

  import HTTPizzaWeb.Templates

  on_mount {HTTPizzaWeb.UserAuth, :ensure_authenticated}
  on_mount {HTTPizzaWeb.Organization, :ensure_organization_selected}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, uri, socket) do
    socket =
      socket
      |> assign(:current_uri, uri)
      |> assign(:http_observer, HTTPizza.Observers.get_http_observer!(id))

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
      <.link
        navigate={~p"/dashboard/#{@current_organization_slug}/observers"}
        class="mb-4 text-sm flex items-center text-zinc-500 hover:text-zinc-800 font-medium"
      >
        <.icon name="hero-chevron-left-mini" class="scale-75" />Back
      </.link>
      <h1 class="text-2xl font-bold font-mono tracking-tight text-blue-500">
        <%= @http_observer.hostname %>
      </h1>
      <p class="text-sm text-zinc-400 font-medium">
        HTTP Observer
      </p>
      <div class="my-4">
        <table>
          <thead>
            <tr>
              <th></th>
              <th class="pr-2 pt-1 text-sm text-zinc-500 text-left">Run at</th>
            </tr>
          </thead>
          <tbody class="text-sm">
            <tr :if={@http_observer.scheduled_at}>
              <td>
                <.icon name="hero-clock" class="text-zinc-500 animate-pulse scale-[85%]" />
              </td>
              <td class="text-xs">
                <span class="text-zinc-500 font-mono">
                  <%= Timex.format!(@http_observer.scheduled_at, "{ISO:Extended:Z}") %>
                </span>
                (<%= Timex.format!(
                  @http_observer.scheduled_at,
                  "{relative}",
                  :relative
                ) %>)
              </td>
            </tr>
            <tr :for={http_observation <- @http_observer.http_observations}>
              <td class="pr-2 pt-1 text-center">
                <.icon
                  name={
                    case http_observation.status do
                      :ok -> "hero-check"
                      :failed -> "hero-x-mark"
                      _ -> "hero-question-mark-circle"
                    end
                  }
                  class={
                    [
                      "scale-[85%]",
                      case http_observation.status do
                        :ok -> "text-green-500"
                        :failed -> "text-red-500"
                        _ -> "text-yellow-500"
                      end
                    ]
                    |> Enum.join(" ")
                  }
                />
              </td>
              <td class="pr-2 pt-1 text-xs">
                <span class="text-zinc-500 font-mono">
                  <%= Timex.format!(http_observation.inserted_at, "{ISO:Extended:Z}") %>
                </span>
                (<%= Timex.format!(
                  http_observation.inserted_at,
                  "{relative}",
                  :relative
                ) %>)
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="flex gap-2">
        <button
          phx-click="delete_http_observer"
          class="font-medium px-3 py-1 bg-red-500 hover:bg-red-600 text-white rounded"
        >
          Delete
        </button>
      </div>
    </.dashboard>
    """
  end

  @impl true
  def handle_event("delete_http_observer", _params, socket) do
    HTTPizza.Observers.delete_http_observer(socket.assigns.http_observer)

    socket =
      socket
      |> put_flash(:info, "HTTP observer deleted")
      |> push_navigate(to: ~p"/dashboard/#{socket.assigns.current_organization_slug}/observers")

    {:noreply, socket}
  end
end
