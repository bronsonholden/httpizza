defmodule HTTPizzaWeb.HTTPObserverLiveTest do
  use HTTPizzaWeb.ConnCase

  import Phoenix.LiveViewTest
  import HTTPizza.{IAMFixtures, ObserversFixtures}

  setup %{conn: conn} do
    user = user_fixture()

    %{conn: log_in_user(conn, user), http_observer: http_observer_fixture()}
  end

  test "renders HTTP observer page", %{conn: conn, http_observer: http_observer} do
    assert {:ok, _live_view, html} =
             live(conn, ~p"/dashboard/personal/observers/#{http_observer.id}")

    assert html =~ http_observer.hostname
  end
end
