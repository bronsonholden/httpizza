defmodule HTTPizzaWeb.ObserverComponents do
  use Phoenix.Component

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
end
