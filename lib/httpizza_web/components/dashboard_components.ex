defmodule HTTPizzaWeb.DashboardComponents do
  use Phoenix.Component
  use HTTPizzaWeb, :verified_routes

  alias Phoenix.LiveView.JS
  alias HTTPizza.IAM.Organization

  import HTTPizzaWeb.CoreComponents, only: [icon: 1, tooltip: 1]

  attr(:organization, :any, required: true)
  attr(:slug, :string, required: true)
  attr(:title, :string, required: true)

  def breadcrumbs(assigns) do
    ~H"""
    <div class="flex gap-2 items-center">
      <.link
        class="font-mono font-bold text-sm text-stone-500 dark:text-stone-400 hover:text-stone-900 dark:hover:text-stone-100"
        navigate={~p"/dashboard/#{@slug}"}
      >
        <%= @slug %>
      </.link>
      <.icon
        name="hero-chevron-right-solid"
        class="shrink-0 font-bold text-stone-500 dark:text-stone-100 scale-75"
      />
      <p class="font-bold text-stone-600 dark:text-stone-100"><%= @title %></p>
    </div>
    """
  end

  attr(:current_uri, :string, required: true)
  attr(:slug, :string, required: true)

  def navigation(assigns) do
    %{path: path} = URI.new!(assigns.current_uri)
    assigns = assign(assigns, :current_path, path)

    ~H"""
    <nav class="flex flex-col gap-1">
      <.navigation_link
        current_path={@current_path}
        path={~p"/dashboard/#{@slug}"}
        icon="hero-lifebuoy"
        label="HTTP Observers"
      />
      <.navigation_link
        current_path={@current_path}
        path={~p"/dashboard/#{@slug}/http-listeners"}
        icon="hero-signal"
        label="HTTP Listeners"
      />
      <.navigation_link
        current_path={@current_path}
        path={~p"/dashboard/#{@slug}/team"}
        icon="hero-users"
        label="Team"
      />
      <.navigation_link
        :if={@slug != "personal"}
        current_path={@current_path}
        path={~p"/dashboard/#{@slug}/billing"}
        icon="hero-banknotes"
        label="Billing"
      />
      <.navigation_link
        current_path={@current_path}
        path={~p"/dashboard/#{@slug}/settings"}
        icon="hero-adjustments-horizontal"
        label="Settings"
      />
    </nav>
    """
  end

  attr(:current_path, :string, required: true)
  attr(:path, :string, required: true)
  attr(:icon, :string, required: true)
  attr(:label, :string, required: true)

  def navigation_link(assigns) do
    ~H"""
    <ul>
      <li class={[
        "hover:bg-stone-100 dark:hover:bg-stone-700 rounded",
        if(is_active?(@current_path, @path),
          do: "bg-stone-100/75 dark:bg-stone-700/70 text-stone-900 dark:text-stone-50",
          else: "text-stone-500 dark:text-stone-400"
        )
      ]}>
        <.link
          class={[
            "block p-2 w-full h-full flex gap-2 items-center text-sm font-medium hover:text-stone-700 dark:hover:text-stone-100"
          ]}
          navigate={@path}
        >
          <.icon name={@icon} /> <%= @label %>
        </.link>
      </li>
    </ul>
    """
  end

  attr(:id, :string, required: true)
  attr(:personal_organization_id, :string, required: true)
  attr(:selection, Organization, required: true)
  attr(:organizations_with_status_counts, :list, required: true)
  attr(:path, :string, default: "")

  def organization_select(assigns) do
    ~H"""
    <div id={@id}>
      <p class="font-bold text-xs text-orange-500 mb-2 ml-3">Organization</p>
      <div class="flex flex-col items-start gap-2">
        <button
          id={"#{@id}-toggle"}
          type="button"
          class="flex items-center font-medium border border-stone-200 dark:border-stone-700 rounded text-sm py-1 px-2 w-full text-left group/button"
          phx-click={JS.toggle(to: "##{@id}-list")}
        >
          <p class="truncate grow">
            <%= display_name(@selection, @personal_organization_id) %>
          </p>

          <p>
            <.icon
              class="text-stone-400 group-hover/button:text-stone-700 dark:group-hover/button:text-stone-100"
              name="hero-chevron-up-down"
            />
          </p>
        </button>

        <div class="relative z-50 w-full">
          <div
            id={"#{@id}-list"}
            phx-click-away={JS.hide()}
            class="bg-white dark:bg-stone-800 absolute top-0 left-0 right-0 rounded border border-stone-200 dark:border-stone-700 py-1 hidden"
          >
            <.link
              :for={%{organization: organization} = item <- @organizations_with_status_counts}
              navigate={
                "/dashboard/#{proper_slug(organization, @personal_organization_id)}#{@path}"
              }
              class="text-sm block p-2 hover:bg-stone-100 dark:hover:bg-stone-700 font-medium"
            >
              <div class="flex items-center gap-1">
                <p class="grow truncate">
                  <%= display_name(organization, @personal_organization_id) %>
                </p>
                <.tooltip id={"#{organization.id}-green-observer-count"}>
                  <:trigger>
                    <p class="text-xs rounded-full px-2 text-white bg-green-500">
                      <%= item.green %>
                    </p>
                  </:trigger>
                  <p class="whitespace-nowrap">No failures in last 24 hours</p>
                </.tooltip>
                <.tooltip id={"#{organization.id}-yellow-observer-count"} direction="bottom">
                  <:trigger>
                    <p
                      :if={item.yellow > 0}
                      class="text-xs rounded-full px-2 text-stone-700 bg-yellow-300"
                    >
                      <%= item.yellow %>
                    </p>
                  </:trigger>
                  <p class="whitespace-nowrap">At least one failure within last 24 hours</p>
                </.tooltip>
                <.tooltip id={"#{organization.id}-red-observer-count"} direction="bottom">
                  <:trigger>
                    <p :if={item.red > 0} class="text-xs rounded-full px-2 text-white bg-red-500">
                      <%= item.red %>
                    </p>
                  </:trigger>
                  <p class="whitespace-nowrap">At least one failure within last hour</p>
                </.tooltip>
              </div>
            </.link>

            <hr class="my-2 border-stone-200 dark:border-stone-700" />

            <.link
              navigate={~p"/organizations/new"}
              class="text-sm block flex items-center p-1 font-medium truncate text-stone-400 hover:text-stone-800 dark:hover:text-stone-100"
            >
              <.icon name="hero-plus-mini" /> New
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp display_name(%Organization{} = organization, personal_organization_id) do
    if organization.id == personal_organization_id do
      "Personal"
    else
      organization.name
    end
  end

  defp proper_slug(%Organization{} = organization, personal_organization_id) do
    if organization.id == personal_organization_id do
      "personal"
    else
      organization.slug
    end
  end

  defp is_active?(current_path, path) do
    # drop `/dashboard/:slug` from paths
    path_matches?(
      String.split(current_path, "/") |> Enum.drop(3) |> Enum.join("/"),
      String.split(path, "/") |> Enum.at(3)
    )
  end

  defp path_matches?(current_path, nil),
    do: current_path == "" or String.starts_with?(current_path, "http-observers")

  defp path_matches?("", path), do: is_nil(path)

  defp path_matches?(current_path, path) do
    String.starts_with?(current_path, path)
  end
end
