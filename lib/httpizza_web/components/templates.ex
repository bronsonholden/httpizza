defmodule HTTPizzaWeb.Templates do
  use Phoenix.Component

  slot(:inner_block)

  def container(assigns) do
    ~H"""
    <div class="p-2 sm:p-4 lg:p-8 max-w-3xl mx-auto p-4">
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
