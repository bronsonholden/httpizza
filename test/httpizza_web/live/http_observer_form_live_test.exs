defmodule HTTPizzaWeb.HTTPObserverFormLiveTest do
  use HTTPizzaWeb.ConnCase

  import Phoenix.LiveViewTest
  import HTTPizza.IAMFixtures

  setup %{conn: conn} do
    user = user_fixture()

    http_observer = %HTTPizza.Observers.HTTPObserver{
      port: 80,
      method: :get,
      schedule: "0 * * * *"
    }

    %{conn: log_in_user(conn, user), http_observer: http_observer}
  end

  test "renders additional sections for header checks", %{
    conn: conn,
    http_observer: http_observer
  } do
    {:ok, live_view, _html} =
      live_isolated(conn, HTTPizzaWeb.HTTPObserverFormLive,
        id: "test-http-observer-form",
        session: %{
          "action" => :new,
          "http_observer" => http_observer,
          "slug" => "personal"
        }
      )

    # start with empty list
    refute has_element?(live_view, "[id=http-observer-header-checks] fieldset")

    assert live_view
           |> element("[phx-click=add_header_check]")
           |> render_click()

    assert has_element?(live_view, "[id=http-observer-header-checks] fieldset")
  end

  test "creates new HTTP observer", %{conn: conn, http_observer: http_observer} do
    {:ok, live_view, _html} =
      live_isolated(conn, HTTPizzaWeb.HTTPObserverFormLive,
        id: "test-http-observer-form",
        session: %{
          "action" => :new,
          "http_observer" => http_observer,
          "slug" => "personal"
        }
      )

    assert live_view
           |> render_change("create", %{
             "http_observer" => %{
               "hostname" => "htt.pizza",
               "path" => "/",
               "port" => 80,
               "https" => false,
               "method" => "get",
               "schedule" => "0 0 * * *",
               "header_checks" => %{
                 "0" => %{
                   "header" => "Location",
                   "comparator" => "equal_to",
                   "value" => "https://htt.pizza/"
                 }
               }
             }
           })

    assert [observer | _] = HTTPizza.Observers.list_http_observers()

    assert [%{header: "Location", comparator: :equal_to, value: "https://htt.pizza/"}] =
             observer.header_checks

    assert_redirected(live_view, ~p"/dashboard/personal")
  end
end
