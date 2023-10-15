defmodule HTTPizzaWeb.EditHTTPObserverLiveTest do
  use HTTPizzaWeb.ConnCase

  import Phoenix.LiveViewTest
  import HTTPizza.{IAMFixtures, ObserversFixtures}

  setup %{conn: conn} do
    user = user_fixture()

    %{conn: log_in_user(conn, user), user: user}
  end

  test "renders edit HTTP observer page", %{conn: conn, user: user} do
    http_observer = http_observer_fixture(%{organization: user.personal_organization})

    assert {:ok, _live_view, html} =
             live(conn, ~p"/dashboard/personal/http-observers/#{http_observer.id}/edit")

    assert html
  end

  test "redirects if editing an HTTP observer for a different account", %{conn: conn, user: user} do
    http_observer = http_observer_fixture(%{organization: user.personal_organization})
    organization = organization_fixture(%{users: [user]})

    result =
      live(conn, ~p"/dashboard/#{organization.slug}/http-observers/#{http_observer.id}/edit")
      |> follow_redirect(conn, ~p"/dashboard/#{organization.slug}")

    assert {:ok, _live_view, _html} = result
  end

  test "deletes HTTP observer", %{conn: conn, user: user} do
    http_observer = http_observer_fixture(%{organization: user.personal_organization})

    {:ok, live_view, _html} =
      live(conn, ~p"/dashboard/personal/http-observers/#{http_observer.id}/edit")

    assert live_view
           |> element("button[phx-click='delete_http_observer']")
           |> render_click()
           |> follow_redirect(conn, ~p"/dashboard/personal")

    assert_raise(Ecto.NoResultsError, fn ->
      HTTPizza.Observers.get_http_observer!(http_observer.id)
    end)
  end
end
