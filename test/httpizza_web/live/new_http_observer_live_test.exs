defmodule HTTPizzaWeb.NewHTTPObserverLiveTest do
  use HTTPizzaWeb.ConnCase

  import Phoenix.LiveViewTest
  import HTTPizza.IAMFixtures

  setup %{conn: conn} do
    user = user_fixture()

    %{conn: log_in_user(conn, user)}
  end

  test "renders new HTTP observer page", %{conn: conn} do
    assert {:ok, _live_view, html} = live(conn, ~p"/dashboard/personal/http-observers/new")

    assert html
  end

  test "renders additional sections for header checks", %{conn: conn} do
    assert {:ok, live_view, _html} = live(conn, ~p"/dashboard/personal/http-observers/new")

    # start with single
    assert has_element?(live_view, "[id=new-http-observer-header-checks] fieldset:nth-of-type(1)")
    refute has_element?(live_view, "[id=new-http-observer-header-checks] fieldset:nth-of-type(2)")

    assert live_view
           |> element("[phx-click=add_header_check]")
           |> render_click()

    assert has_element?(live_view, "[id=new-http-observer-header-checks] fieldset:nth-of-type(2)")
  end

  test "creates new HTTP observer", %{conn: conn} do
    assert {:ok, live_view, _html} = live(conn, ~p"/dashboard/personal/http-observers/new")

    assert live_view
           |> render_change("create", %{
             "http_observer" => %{
               "hostname" => "htt.pizza",
               "path" => "/",
               "port" => 80,
               "https" => false,
               "method" => "get",
               "schedule" => "0 0 * * *",
               "http_head_checks" => %{
                 "0" => %{
                   "header" => "Location",
                   "comparator" => "equal_to",
                   "value" => "https://htt.pizza/"
                 }
               }
             }
           })

    assert [observer | _] =
             HTTPizza.Observers.list_http_observers() |> HTTPizza.Repo.preload(:http_head_checks)

    assert [%{header: "Location", comparator: :equal_to, value: "https://htt.pizza/"}] =
             observer.http_head_checks

    assert_redirected(live_view, ~p"/dashboard/personal/observers")
  end
end
