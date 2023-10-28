defmodule HTTPizzaWeb.LandingLive do
  use HTTPizzaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-md md:max-w-5xl mx-auto p-4 md:p-12">
      <h1 class="text-6xl md:text-8xl font-black text-orange-400/90 text-center">
        HTTPizza
      </h1>

      <div class="my-12 md:my-20">
        <h2 class="font-black text-4xl text-stone-600 dark:text-stone-100">
          Pie in the Sky!
        </h2>

        <p class="my-4 text-lg text-stone-600 dark:text-stone-100 font-medium md:w-1/2">
          All of the observability with none of the hassle. Stay in the know with HTTP observers that
          run on a <span class="font-mono font-black">cron</span>
          schedule at intervals as low as 1 minute.
        </p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 md:gap-12 my-4 md:my-8">
        <.step_card number="1">
          Configure an observer for your website or API service with header and status checks.
        </.step_card>

        <.step_card number="2">
          Select email addresses to notify based on results: successes, failures, or unexpected errors.
        </.step_card>

        <.step_card number="3">
          When a failure occurs, get notified immediately so you can resolve the issue.
        </.step_card>
      </div>

      <p class="mt-8 md:mt-20 text-2xl text-orange-400 font-bold">That's it!</p>
      <.link
        class="shadow-md my-6 inline-block p-3 text-lg text-white rounded bg-orange-500 hover:bg-orange-400 font-black"
        navigate={~p"/users/log_in"}
      >
        Get started <.icon name="hero-arrow-right-mini" />
      </.link>
    </div>
    """
  end

  attr(:number, :string)
  slot(:inner_block, required: true)

  defp step_card(assigns) do
    ~H"""
    <div class="grow">
      <.badge><%= @number %></.badge>
      <p class="font-medium text-stone-600 dark:text-stone-100">
        <%= render_slot(@inner_block) %>
      </p>
    </div>
    """
  end

  slot(:inner_block, required: true)

  defp badge(assigns) do
    ~H"""
    <div class="shadow-lg my-6 bg-orange-500/10 dark:bg-orange-400/20 text-orange-400 rounded p-5 text-xl font-black w-8 h-8 flex items-center justify-center">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
