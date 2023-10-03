defmodule HTTPizzaWeb.LandingLive do
  use HTTPizzaWeb, :live_view

  import HTTPizzaWeb.Templates

  on_mount {HTTPizzaWeb.UserAuth, :redirect_if_user_is_authenticated}

  def render(assigns) do
    ~H"""
    <.container>
      Landing
    </.container>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
