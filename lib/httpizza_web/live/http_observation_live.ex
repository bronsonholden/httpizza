defmodule HTTPizzaWeb.HTTPObservationLive do
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
    http_observation = HTTPizza.Observers.get_http_observation!(id)

    socket =
      socket
      |> assign(:current_uri, uri)
      |> assign(:http_observation, http_observation)

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
        navigate={~p"/dashboard/#{@current_organization_slug}"}
        class="mb-4 text-sm flex items-center text-zinc-500 hover:text-zinc-800 font-medium"
      >
        <.icon name="hero-chevron-left-mini" class="scale-75" />Back
      </.link>

      <table>
        <thead>
          <tr class="text-xs text-zinc-400">
            <th></th>
            <th class="text-left">Check</th>
            <th class="text-left">Result</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={check_result <- @http_observation.check_results}>
            <td class="pr-4 pt-2">
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
                    "scale-75",
                    case check_result.status do
                      :ok -> "text-green-500"
                      :failed -> "text-red-500"
                      :error -> "text-zinc-500"
                    end
                  ]
                  |> Enum.join(" ")
                }
              />
            </td>
            <td class="pr-4 pt-2 font-medium">
              <%= display_kind(check_result.kind) %>
            </td>
            <td class="pr-4 pt-2">
              <%= check_result.reason %>
            </td>
          </tr>
        </tbody>
      </table>
    </.dashboard>
    """
  end

  defp display_kind(module_name) do
    # Elixir.HTTPizza.Checks.{CheckModuleName}
    String.split(module_name, ".")
    |> Enum.at(3)
    |> String.replace("Check", "")
  end
end
