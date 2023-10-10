defmodule HTTPizzaWeb.ObserverComponents do
  use Phoenix.Component

  import HTTPizzaWeb.CoreComponents, only: [icon: 1]

  attr(:check, :any, required: true)

  def check_list_item(%{check: %HTTPizza.Checks.HeaderCheck{}} = assigns) do
    ~H"""
    <p class="font-mono font-medium text-xs">
      <span class="text-zinc-500"><%= @check.header %></span>
      <span class="rounded px-1 py-[2px] bg-zinc-200"><%= @check.comparator %></span>
      <span class="text-zinc-500"><%= @check.value %></span>
    </p>
    """
  end

  def check_list_icon(assigns) do
    ~H"""
    <p class="inline-block text-zinc-500 font-bold pb-2 align-text-top mr-2">↳</p>
    """
  end

  attr(:http_observations, :list, required: true)

  def status_bar(assigns) do
    ~H"""
    <div class="overflow-hidden w-full relative h-[1rem]">
      <div class="absolute top-0 bottom-0 right-0 flex flex-row-reverse gap-[2px]">
        <div
          :for={http_observation <- Enum.take(@http_observations, 200)}
          class={[
            "rounded w-[4px] h-full",
            case http_observation.status do
              :ok -> "bg-green-500"
              :failed -> "bg-red-500"
              _ -> "bg-zinc-500"
            end
          ]}
        />
      </div>
    </div>
    """
  end

  def timeline_guide(assigns) do
    ~H"""
    <div class="w-full flex justify-between items-center text-zinc-400 text-xs my-4 gap-2">
      <p class="flex items-center italic">
        <.icon name="hero-arrow-left-mini" class="scale-50" /> older
      </p>
      <hr class="grow border-t-[1px] border-zinc-200" />
      <p class="flex items-center italic">
        newer <.icon name="hero-arrow-right-mini" class="scale-50" />
      </p>
    </div>
    """
  end
end
