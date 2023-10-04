defmodule HTTPizzaWeb.DashboardLive do
  alias HTTPizzaWeb.DashboardComponents
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
  def handle_params(_, _, %{assigns: %{current_organization: %IAM.Organization{}}} = socket) do
    {:noreply, socket}
  end

  def handle_params(_, _, socket),
    do: {:noreply, push_navigate(socket, to: ~p"/dashboard/personal")}

  @impl true
  def render(assigns) do
    ~H"""
    <.container>
      <div class="flex flex-col gap-4">
        <DashboardComponents.organization_select
          id="organization-select"
          selection={@current_organization}
          organizations={@current_user.organizations}
          personal_organization_id={@current_user.personal_organization.id}
        />

        <nav class="py border rounded-lg w-[14rem]">
          <ul class="my-2">
            <li class="hover:bg-zinc-100">
              <.link
                class="block p-2 w-full h-full flex gap-2 items-center text-sm font-medium text-zinc-600 hover:text-zinc-700"
                navigate={
                  ~p"/dashboard/#{HTTPizzaWeb.Slug.humanize(@current_organization.slug, @current_user.personal_organization.slug)}/observers"
                }
              >
                <.icon name="hero-lifebuoy-mini" /> Observers
              </.link>
            </li>
          </ul>
        </nav>
      </div>
    </.container>
    """
  end
end
