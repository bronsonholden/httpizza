defmodule HTTPizzaWeb.ObserverComponents do
  use Phoenix.Component
  use HTTPizzaWeb, :verified_routes

  import HTTPizzaWeb.CoreComponents, only: [icon: 1]

  attr(:check, :any, required: true)

  def check_list_item(%{check: %HTTPizza.Checks.HeaderCheck{}} = assigns) do
    ~H"""
    <p class="font-mono font-medium text-xs">
      <span class="text-stone-500"><%= @check.header %></span>
      <span class="rounded px-1 py-[2px] bg-stone-200"><%= @check.comparator %></span>
      <span class="text-stone-500"><%= @check.value %></span>
    </p>
    """
  end

  def check_list_item(%{check: %HTTPizza.Checks.StatusCheck{}} = assigns) do
    ~H"""
    <p class="font-mono font-medium text-xs">
      <span class="text-stone-500">Status</span>
      <span class="rounded px-1 py-[2px] bg-stone-200"><%= @check.comparator %></span>
      <span :if={@check.comparator == :equal_to} class="text-stone-500"><%= @check.code %></span>
    </p>
    """
  end

  def check_list_icon(assigns) do
    ~H"""
    <p class="inline-block text-stone-500 font-bold pb-2 align-text-top mr-2 text-base font-serif">
      ↳
    </p>
    """
  end

  attr(:http_observations, :list, required: true)
  attr(:slug, :string, required: true)

  def status_bar(assigns) do
    ~H"""
    <div class="overflow-hidden w-full relative h-[1.5rem] z-0">
      <div class="pointer-events-none absolute top-0 left-0 right-1/3 bottom-0 bg-gradient-to-r from-white/20 z-50" />
      <div class="pointer-events-none absolute top-0 left-0 right-[90%] bottom-0 bg-gradient-to-r from-white/90 z-50" />
      <div class="absolute top-0 bottom-0 right-0 flex flex-row-reverse z-40">
        <.link
          :for={http_observation <- Enum.take(@http_observations, 60)}
          navigate={~p"/dashboard/#{@slug}/http-observations/#{http_observation.id}"}
          class="w-[13px] sm:w-[11px] h-full p-[2px] group/pill"
        >
          <div class={[
            "h-full w-full rounded-full group-hover/pill:scale-[110%]",
            status_classes(http_observation)
          ]}>
          </div>
        </.link>
      </div>
    </div>
    """
  end

  defp status_classes(%{resolved: true}) do
    "bg-amber-400 group-hover/pill:bg-amber-300"
  end

  defp status_classes(http_observation) do
    case http_observation.status do
      :ok -> "bg-green-500 group-hover/pill:bg-green-400"
      :failed -> "bg-red-500 group-hover/pill:bg-red-400"
      _ -> "bg-stone-500 group-hover/pill:bg-stone-400"
    end
  end

  def timeline_guide(assigns) do
    ~H"""
    <div class="w-full flex justify-between items-center text-stone-400 dark:text-stone-100 text-xs my-4 gap-2">
      <p class="flex items-center italic">
        <.icon name="hero-arrow-left-mini" class="scale-50" /> older
      </p>
      <hr class="grow border-t-[1px] border-stone-200" />
      <p class="flex items-center italic">
        newer <.icon name="hero-arrow-right-mini" class="scale-50" />
      </p>
    </div>
    """
  end
end
