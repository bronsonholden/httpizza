defmodule HTTPizzaWeb.LandingLive do
  use HTTPizzaWeb, :live_view

  on_mount {HTTPizzaWeb.UserAuth, :redirect_if_user_is_authenticated}

  def render(assigns) do
    ~H"""
    <div>
      Landing
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
