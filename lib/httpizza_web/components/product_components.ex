defmodule HTTPizzaWeb.ProductComponents do
  use Phoenix.Component
  use HTTPizzaWeb, :verified_routes

  import HTTPizzaWeb.CoreComponents, only: [icon: 1]

  def feature_list(assigns) do
    ~H"""
    <ul class="text-stone-700 dark:text-stone-200 space-y-1">
      <%= render_slot(@inner_block) %>
    </ul>
    """
  end

  attr(:icon, :string, required: true)
  slot(:inner_block, required: true)

  def feature_list_item(assigns) do
    ~H"""
    <li class="flex items-center gap-2 font-medium">
      <.icon name={@icon} class="scale-[85%]" /> <%= render_slot(@inner_block) %>
    </li>
    """
  end

  attr(:plan, :string, values: ["plus", "pro", "free"])

  def plan_feature_list(%{plan: "free"} = assigns) do
    ~H"""
    <.feature_list>
      <.feature_list_item icon="hero-clock">1-hour schedule</.feature_list_item>
      <.feature_list_item icon="hero-lifebuoy">Up to 5 HTTP observers</.feature_list_item>
      <.feature_list_item icon="hero-user-group">Up to 2 team members</.feature_list_item>
      <.feature_list_item icon="hero-trash">No marketing emails—ever</.feature_list_item>
    </.feature_list>
    """
  end

  def plan_feature_list(%{plan: "plus"} = assigns) do
    ~H"""
    <.feature_list>
      <.feature_list_item icon="hero-clock">5-minute schedule</.feature_list_item>
      <.feature_list_item icon="hero-lifebuoy">Up to 25 HTTP observers</.feature_list_item>
      <.feature_list_item icon="hero-user-group">Up to 5 team members</.feature_list_item>
      <.feature_list_item icon="hero-trash">No marketing emails—ever</.feature_list_item>
    </.feature_list>
    """
  end

  def plan_feature_list(%{plan: "pro"} = assigns) do
    ~H"""
    <.feature_list>
      <.feature_list_item icon="hero-clock">No schedule limits</.feature_list_item>
      <.feature_list_item icon="hero-lifebuoy">Unlimited HTTP observers</.feature_list_item>
      <.feature_list_item icon="hero-user-group">Unlimited team members</.feature_list_item>
      <.feature_list_item icon="hero-trash">No marketing emails—ever</.feature_list_item>
    </.feature_list>
    """
  end
end
