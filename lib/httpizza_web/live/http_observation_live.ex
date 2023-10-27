defmodule HTTPizzaWeb.HTTPObservationLive do
  alias HTTPizzaWeb.ObserverComponents
  use HTTPizzaWeb, :live_view

  alias HTTPizza.Observers

  import HTTPizzaWeb.Templates

  on_mount {HTTPizzaWeb.UserAuth, :ensure_authenticated}
  on_mount {HTTPizzaWeb.Organization, :ensure_organization_selected}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, uri, socket) do
    Observers.get_organization_observation(socket.assigns.current_organization.id, id)
    |> case do
      nil ->
        {:noreply,
         push_navigate(socket, to: ~p"/dashboard/#{socket.assigns.current_organization_slug}")}

      http_observation ->
        socket =
          socket
          |> assign(:http_observation, http_observation)
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
      <div class="flex items-start justify-between">
        <div class="mb-6">
          <p class={[
            "font-bold text-xl",
            if(@http_observation.status == :ok, do: "text-green-500", else: "text-red-500")
          ]}>
            <%= @http_observation.reason %>
          </p>

          <p class="text-stone-400 text-xs">
            <%= Timex.format!(@http_observation.inserted_at, "{relative}", :relative) %>
          </p>
        </div>
        <.link
          navigate={~p"/dashboard/#{@current_organization_slug}"}
          class="mb-4 text-sm flex items-center text-stone-500 hover:text-stone-800 dark:hover:text-stone-100 font-medium"
        >
          <.icon name="hero-arrow-uturn-left" />
        </.link>
      </div>

      <div class="flex my-4">
        <.tooltip :if={@http_observation.status == :failed} id="mark-as-resolved-tooltip">
          <:trigger>
            <button
              id="resolve_http_observation"
              disabled={@http_observation.resolved}
              phx-click="resolve"
              class="group/resolve border-2 rounded px-2 font-medium text-sm py-1 border-blue-500 text-blue-500 disabled:text-green-500/40 disabled:border-green-500/40"
            >
              <span class="group-disabled/resolve:hidden">Mark as resolved</span>
              <span class="hidden group-disabled/resolve:block">
                <.icon name="hero-check-mini" class="scale-75" /> Resolved
              </span>
            </button>
          </:trigger>
          <p class="min-w-[14rem]">Resolved failures don't affect observer status.</p>
        </.tooltip>
      </div>

      <div :for={check_result <- @http_observation.check_results}>
        <div class="flex gap-2 items-start">
          <.icon
            name={
              case check_result.status do
                :ok -> "hero-check"
                :failed -> "hero-x-mark"
                :error -> "hero-x-mark"
              end
            }
            class={
              [
                "scale-75 mt-[6px]",
                case check_result.status do
                  :ok -> "text-green-500"
                  :failed -> "text-red-500"
                  :error -> "text-stone-500"
                end
              ]
              |> Enum.join(" ")
            }
          />
          <div class="w-2/3 pr-4 pt-2 font-medium">
            <ObserverComponents.check_list_item check={get_check(check_result)} />
            <div class="text-xs font-mono text-stone-500 flex">
              <ObserverComponents.check_list_icon />
              <p class="mt-2">
                <%= check_result.reason %>
              </p>
            </div>
          </div>
        </div>
      </div>
    </.dashboard>
    """
  end

  @impl true
  def handle_event("resolve", _params, socket) do
    with {:ok, _} <-
           socket.assigns.http_observation
           |> Observers.update_http_observation(%{resolved: true}) do
      socket =
        socket
        |> put_flash(:info, "Marked as resolved")
        |> push_navigate(to: ~p"/dashboard/#{socket.assigns.current_organization_slug}")

      {:noreply, socket}
    else
      _ -> {:noreply, put_flash(socket, :error, "Unable to mark as resolved")}
    end
  end

  defp get_check(%{kind: "Elixir.HTTPizza.Checks.HeaderCheck"} = check_result) do
    check_result.header_check
  end

  defp get_check(%{kind: "Elixir.HTTPizza.Checks.StatusCheck"} = check_result) do
    check_result.status_check
  end
end
