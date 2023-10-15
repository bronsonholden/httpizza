defmodule HTTPizzaWeb.Templates do
  use Phoenix.Component

  alias HTTPizzaWeb.DashboardComponents

  import HTTPizzaWeb.CoreComponents, only: [icon: 1]

  attr(:current_uri, :string, required: true)
  attr(:current_organization, :any, required: true)
  attr(:personal_organization, :any, required: true)
  attr(:organizations_with_status_counts, :list, required: true)
  attr(:slug, :string, required: true)

  attr(:path, :string,
    default: "",
    doc:
      "Appended to dashboard path so switching between organizations on e.g. the settings page keeps you on the settings page"
  )

  slot(:org)
  slot(:nav)
  slot(:inner_block)

  def dashboard(assigns) do
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
                organizations_with_status_counts={@organizations_with_status_counts}
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
            "md:min-w-[22rem] md:w-[22rem] md:max-w-[22rem] flex flex-col gap-4"
          ]}>
            <div class="p-4 rounded-lg bg-white shadow">
              <h2 class="text-xl font-bold text-zinc-800">Getting Started</h2>
              <p class="text-sm text-zinc-500 font-medium my-2">
                HTTPizza is a practical monitoring system for websites and APIs—any online service
                can be observed, alerting you when outages or errors occur.
              </p>
              <p class="text-xs text-zinc-400 mt-3 font-medium">
                * Pizza delivery notifications coming soon
              </p>
            </div>

            <div class="p-4 rounded-lg bg-white shadow">
              <h2 class="text-xl font-bold text-zinc-800">Example use cases</h2>
              <p class="text-sm text-zinc-500 font-medium my-2">
                Not sure what to do? Try these!
              </p>
              <ul class="text-sm text-zinc-500">
                <li class="flex items-start gap-2">
                  <.icon name="hero-chevron-right" class="shrink-0 scale-[65%] text-zinc-500" />
                  <p>
                    Verify non-<span class="font-mono bg-zinc-100 px-1">www</span> to
                    <span class="font-mono bg-zinc-100 px-1">www</span>
                    redirects (or vice versa).
                  </p>
                </li>
                <li class="flex items-start gap-2">
                  <.icon name="hero-chevron-right" class="shrink-0 scale-[65%] text-zinc-500" />
                  <p>Security probing—ensure unauthenticated requests receive appropriate errors.</p>
                </li>
                <li class="flex items-start gap-2">
                  <.icon name="hero-chevron-right" class="shrink-0 scale-[65%] text-zinc-500" />
                  <p>Performance monitoring—be alerted when endpoints take too long to respond.</p>
                </li>
              </ul>
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
