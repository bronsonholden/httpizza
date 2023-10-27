defmodule HTTPizzaWeb.JoinTeamLiveTest do
  use HTTPizzaWeb.ConnCase

  alias HTTPizza.IAM

  import Phoenix.LiveViewTest
  import HTTPizza.IAMFixtures

  setup do
    organization = organization_fixture()
    user = user_fixture(%{password: "TheOGPassword"})

    encoded_token =
      extract_user_token(fn url ->
        IAM.deliver_user_invite_to_organization(
          user,
          organization,
          url
        )
      end)

    %{organization: organization, user: user, encoded_token: encoded_token}
  end

  test "redirects away if logged in as a different user", %{
    conn: conn,
    user: user,
    organization: organization,
    encoded_token: encoded_token
  } do
    conn = log_in_user(conn, user_fixture())

    refute IAM.organization_has_user_by_email?(organization, user.email)

    {:ok, _live_view, html} =
      live(conn, ~p"/dashboard/#{organization.slug}/team/join/#{encoded_token}")
      |> follow_redirect(conn, ~p"/dashboard/personal")

    assert html =~ "This invite link is not valid for your account."

    refute IAM.organization_has_user_by_email?(organization, user.email)
  end

  test "accepts invite for intended user when logged in", %{
    conn: conn,
    user: user,
    organization: organization,
    encoded_token: encoded_token
  } do
    conn = log_in_user(conn, user)

    refute IAM.organization_has_user_by_email?(organization, user.email)

    {:ok, live_view, _html} =
      live(conn, ~p"/dashboard/#{organization.slug}/team/join/#{encoded_token}")

    {:ok, _live_view, html} =
      live_view
      |> render_submit("join", %{})
      |> follow_redirect(conn, ~p"/dashboard/#{organization.slug}")

    assert html =~ "Welcome to the #{organization.name} team!"

    assert IAM.organization_has_user_by_email?(organization, user.email)
  end

  test "does not set password for signed-in user", %{
    conn: conn,
    user: user,
    organization: organization,
    encoded_token: encoded_token
  } do
    conn = log_in_user(conn, user)

    refute IAM.organization_has_user_by_email?(organization, user.email)

    {:ok, live_view, _html} =
      live(conn, ~p"/dashboard/#{organization.slug}/team/join/#{encoded_token}")

    # since they're logged in, they don't need to set a password
    refute has_element?(live_view, "input[type=password]")

    live_view
    |> render_submit("join", %{
      "password" => "ThisCantBeHappening",
      "password_confirmation" => "ThisCantBeHappening"
    })

    refute IAM.User.valid_password?(user, "ThisCantBeHappening")
    assert IAM.User.valid_password?(user, "TheOGPassword")
    assert IAM.organization_has_user_by_email?(organization, user.email)
  end

  test "does not set password if user has ever signed in", %{
    conn: conn,
    user: user,
    organization: organization,
    encoded_token: encoded_token
  } do
    refute IAM.organization_has_user_by_email?(organization, user.email)

    {:ok, _} =
      user
      |> IAM.User.last_logged_in_changeset()
      |> HTTPizza.Repo.update()

    {:ok, live_view, _html} =
      live(conn, ~p"/dashboard/#{organization.slug}/team/join/#{encoded_token}")

    # since they've logged in previously, they don't need to set
    refute has_element?(live_view, "input[type=password]")

    live_view
    |> render_submit("join", %{
      "password" => "ThisCantBeHappening",
      "password_confirmation" => "ThisCantBeHappening"
    })

    refute IAM.User.valid_password?(user, "ThisCantBeHappening")
    assert IAM.User.valid_password?(user, "TheOGPassword")
    assert IAM.organization_has_user_by_email?(organization, user.email)
  end

  test "sets password for user if they have never logged in", %{
    conn: conn,
    user: user,
    organization: organization,
    encoded_token: encoded_token
  } do
    refute IAM.organization_has_user_by_email?(organization, user.email)

    {:ok, live_view, _html} =
      live(conn, ~p"/dashboard/#{organization.slug}/team/join/#{encoded_token}")

    assert has_element?(live_view, "input[type=password]")

    assert live_view
           |> render_submit("join", %{
             "user" => %{
               "password" => "HeyThereItsMe",
               "password_confirmation" => "HeyThereItsMe"
             }
           })
           |> follow_redirect(conn, ~p"/users/log_in")

    # reload user to get updated hashed password
    assert user = IAM.get_user_by_email(user.email)
    refute IAM.User.valid_password?(user, "TheOGPassword")
    assert IAM.User.valid_password?(user, "HeyThereItsMe")
    assert IAM.organization_has_user_by_email?(organization, user.email)
  end
end
