defmodule HTTPizzaWeb.NewOrganizationLiveTest do
  use HTTPizzaWeb.ConnCase

  import Phoenix.LiveViewTest
  import HTTPizza.IAMFixtures

  setup %{conn: conn} do
    user = user_fixture()

    %{conn: log_in_user(conn, user), user: user}
  end

  test "redirects to dashboard page for created organization", %{conn: conn, user: user} do
    {:ok, live_view, _html} = live(conn, ~p"/organizations/new")

    result =
      live_view
      |> render_change("create", %{
        "organization" => %{"name" => "Globex Corporation", "slug" => "globex"}
      })
      |> follow_redirect(conn, ~p"/dashboard/globex")

    assert {:ok, live_view, _html} = result

    assert has_element?(live_view, "#organization-select [href*=globex]", "Globex Corporation")

    assert %{id: id} = HTTPizza.IAM.get_organization_by_slug!("globex")

    assert_enqueued(
      worker: HTTPizza.CreateStripeCustomerWorker,
      args: %{"id" => id, "name" => "Globex Corporation", "email" => user.email}
    )
  end
end
