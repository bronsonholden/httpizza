defmodule HTTPizzaWeb.HTTPListenersLive do
  use HTTPizzaWeb, :live_view

  alias HTTPizza.IAM
  alias HTTPizzaWeb.DashboardComponents

  import HTTPizzaWeb.Templates

  on_mount {HTTPizzaWeb.UserAuth, :ensure_authenticated}
  on_mount {HTTPizzaWeb.Organization, :mount_current_organization}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_, uri, %{assigns: %{current_organization: %IAM.Organization{}}} = socket) do
    socket =
      socket
      |> assign(:current_uri, uri)

    {:noreply, socket}
  end

  def handle_params(_, _, socket),
    do: {:noreply, push_navigate(socket, to: ~p"/dashboard/personal")}

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
      <div class="flex items-start justify-between w-full">
        <DashboardComponents.breadcrumbs
          organization={@current_organization}
          slug={@current_organization_slug}
          title="HTTP Listeners"
        />
        <.link
          :if={false}
          class="h-full py-1 pl-1 pr-2 text-xs font-bold hover:bg-orange-400 rounded text-white bg-orange-500 flex items-center gap-1"
          navigate={~p"/dashboard/#{@current_organization_slug}/http-listeners/new"}
        >
          <.icon name="hero-plus-mini" class="scale-75" /> New
        </.link>
      </div>

      <p class="font-bold text-lg text-stone-300 dark:text-stone-500 mx-auto max-w-xs text-center mt-12 mb-24">
        Coming soon!
      </p>
    </.dashboard>
    """
  end
end
