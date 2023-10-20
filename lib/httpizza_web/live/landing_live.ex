defmodule HTTPizzaWeb.LandingLive do
  use HTTPizzaWeb, :live_view

  def render(assigns) do
    ~H"""

    """
  end

  def mount(_params, _session, socket) do
    {:ok, push_navigate(socket, to: ~p"/users/log_in")}
  end
end
