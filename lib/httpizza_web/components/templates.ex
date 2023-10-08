defmodule HTTPizzaWeb.Templates do
  use Phoenix.Component

  alias HTTPizzaWeb.DashboardComponents

  attr(:current_uri, :string, required: true)
  attr(:current_organization, :any, required: true)
  attr(:personal_organization, :any, required: true)
  attr(:organizations, :list, required: true)

  slot(:org)
  slot(:nav)
  slot(:inner_block)

  def dashboard(assigns) do
    parts =
      assigns.current_uri
      |> URI.new!()
      |> Map.get(:path)
      |> String.split("/")
      # ["", "dashboard", _slug]
      |> Enum.drop(3)

    path = Enum.join(["" | parts], "/")

    assigns =
      assigns
      |> assign(
        :slug,
        HTTPizzaWeb.Slug.humanize(
          assigns.current_organization.slug,
          assigns.personal_organization.slug
        )
      )
      |> assign(:path, path)

    ~H"""
    <div class="w-full bg-slate-100 relative min-h-[calc(100vh-64px)]">
      <div class="max-md:hidden absolute left-0 top-0 bottom-0 right-1/2 bg-white" />
      <div class="grow max-w-[96rem] mx-auto h-full flex flex-col md:flex-row bg-white min-h-[calc(100vh-64px)]">
        <div class={[
          "grow flex flex-col",
          "xl:flex-row"
        ]}>
          <div class={[
            "bg-white z-50",
            "flex flex-col gap-4",
            "xl:w-[20rem] xl:px-4 xl:min-w-[20rem] xl:max-w-[20rem]"
          ]}>
            <div class={[
              "max-xl:px-4",
              "pt-4"
            ]}>
              <DashboardComponents.organization_select
                id="organization-select"
                selection={@current_organization}
                organizations={@organizations}
                personal_organization_id={@personal_organization.id}
                path={@path}
              />
            </div>

            <div class="max-xl:px-4">
              <DashboardComponents.navigation current_uri={@current_uri} slug={@slug} />
            </div>
          </div>

          <div class={[
            "bg-white z-40",
            "max-xl:px-4",
            "xl:grow xl:p-5 xl:border-l xl:shadow-md"
          ]}>
            <%= render_slot(@inner_block) %>
          </div>
        </div>
        <div class={[
          "bg-slate-100 p-4"
        ]}>
          <div class={[
            "md:min-w-[22rem] md:w-[22rem] md:max-w-[22rem]"
          ]}>
            <div class="p-4 rounded-lg bg-white shadow">
              <h2 class="text-xl font-bold">Getting Started</h2>
              <p class="text-sm text-zinc-500 font-medium my-2">
                HTTPizza is a practical monitoring system for websites and APIs—any online service
                can be observed, alerting you when outages or errors occur.
              </p>
              <p class="text-xs text-zinc-400 mt-3 font-medium">
                * Pizza delivery notifications coming soon
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr(:size, :string, default: "lg")
  slot(:inner_block)

  def container(assigns) do
    ~H"""
    <div class={[
      "p-2 sm:p-4 lg:p-8 mx-auto p-4",
      case @size do
        "sm" -> "max-w-sm"
        "md" -> "max-w-lg"
        "lg" -> "max-w-3xl"
      end
    ]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
