defmodule HTTPizzaWeb.Templates do
  use Phoenix.Component

  attr(:size, :string, default: "lg")
  slot(:inner_block)

  def container(assigns) do
    ~H"""
    <div class={[
      "p-2 sm:p-4 lg:p-8 mx-auto p-4",
      case @size do
        "sm" -> "max-w-md"
        "md" -> "max-w-lg"
        "lg" -> "max-w-3xl"
      end
    ]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  slot(:inner_block)

  def card(assigns) do
    ~H"""
    <div class="shadow-sm border rounded-xl p-4">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
