defmodule HTTPizzaWeb.DashboardComponents do
  use Phoenix.Component
  use HTTPizzaWeb, :verified_routes

  alias Phoenix.LiveView.JS

  import HTTPizzaWeb.CoreComponents, only: [icon: 1]

  attr(:id, :string, required: true)
  attr(:personal_organization_id, :string, required: true)
  attr(:selection, :any, required: true)
  attr(:organizations, :list, required: true)

  @spec organization_select(map) :: Phoenix.LiveView.Rendered.t()
  def organization_select(assigns) do
    ~H"""
    <div>
      <p class="font-bold text-xs text-orange-500 mb-2 ml-3">Organization</p>
      <div class="flex items-start gap-2">
        <button
          id={@id}
          type="button"
          class="flex items-center font-medium border rounded-xl p-3 w-[14rem] text-left"
          phx-click={JS.toggle(to: "##{@id}-list")}
        >
          <p class="truncate grow">
            <%= display_name(@selection, @personal_organization_id) %>
          </p>

          <p>
            <.icon class="text-regular" name="hero-chevron-up-down" />
          </p>
        </button>

        <div class="relative">
          <div
            id={"#{@id}-list"}
            phx-click-away={JS.hide()}
            class="bg-white absolute top-0 w-[18rem] rounded-xl border py-2 hidden"
          >
            <.link
              :for={organization <- @organizations}
              navigate={~p"/dashboard/#{proper_slug(organization, @personal_organization_id)}"}
              class="block p-2 hover:bg-zinc-100 font-medium truncate"
            >
              <%= display_name(@selection, @personal_organization_id) %>
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp display_name(organization, personal_organization_id) do
    if organization.id == personal_organization_id do
      "Personal"
    else
      organization.name
    end
  end

  defp proper_slug(organization, personal_organization_id) do
    if organization.id == personal_organization_id do
      "personal"
    else
      organization.slug
    end
  end
end
