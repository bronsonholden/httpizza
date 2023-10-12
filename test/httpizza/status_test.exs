defmodule HTTPizza.StatusTest do
  use HTTPizza.DataCase

  alias HTTPizza.Status

  describe "get_organizations_with_status_counts/1" do
    import HTTPizza.{IAMFixtures, ObserversFixtures}

    setup do
      user = user_fixture()

      %{user: user}
    end

    test "returns zero-counts with no observers", %{user: user} do
      assert [%{green: 0, yellow: 0, red: 0}] =
               Status.get_organizations_with_status_counts(user)
    end

    test "returns all green with no observations", %{user: user} do
      http_observer_fixture(%{organization: user.personal_organization})

      assert [%{green: 1, yellow: 0, red: 0}] =
               Status.get_organizations_with_status_counts(user)
    end

    test "returns green with failure > 1 day ago", %{user: user} do
      http_observer = http_observer_fixture(%{organization: user.personal_organization})

      http_observation =
        http_observation_fixture(%{
          http_observer_id: http_observer.id,
          status: :failed,
          reason: "Test"
        })

      {:ok, _} = time_travel(http_observation, DateTime.add(DateTime.utc_now(), -1, :day))

      assert [%{green: 1, yellow: 0, red: 0}] =
               Status.get_organizations_with_status_counts(user)
    end

    test "returns yellow with failure < 1 day ago and > 1 hr ago", %{user: user} do
      http_observer = http_observer_fixture(%{organization: user.personal_organization})

      http_observation =
        http_observation_fixture(%{
          http_observer_id: http_observer.id,
          status: :failed,
          reason: "Test"
        })

      {:ok, _} = time_travel(http_observation, DateTime.add(DateTime.utc_now(), -2, :hour))

      assert [%{green: 0, yellow: 1, red: 0}] =
               Status.get_organizations_with_status_counts(user)
    end

    test "returns red with failure < 1 hr ago", %{user: user} do
      http_observer = http_observer_fixture(%{organization: user.personal_organization})

      http_observation =
        http_observation_fixture(%{
          http_observer_id: http_observer.id,
          status: :failed,
          reason: "Test"
        })

      {:ok, _} = time_travel(http_observation, DateTime.add(DateTime.utc_now(), -20, :minute))

      assert [%{green: 0, yellow: 0, red: 1}] =
               Status.get_organizations_with_status_counts(user)
    end

    test "returns red if also has a yellow failure", %{user: user} do
      http_observer = http_observer_fixture(%{organization: user.personal_organization})

      {:ok, _} =
        time_travel(
          http_observation_fixture(%{
            http_observer_id: http_observer.id,
            status: :failed,
            reason: "Red"
          }),
          DateTime.add(DateTime.utc_now(), -20, :minute)
        )

      {:ok, _} =
        time_travel(
          http_observation_fixture(%{
            http_observer_id: http_observer.id,
            status: :failed,
            reason: "Yellow"
          }),
          DateTime.add(DateTime.utc_now(), -80, :minute)
        )

      assert [%{green: 0, yellow: 0, red: 1}] =
               Status.get_organizations_with_status_counts(user)
    end

    test "returns one status per observer", %{user: user} do
      green = http_observer_fixture(%{organization: user.personal_organization})
      yellow = http_observer_fixture(%{organization: user.personal_organization})
      red = http_observer_fixture(%{organization: user.personal_organization})

      {:ok, _} =
        time_travel(
          http_observation_fixture(%{
            http_observer_id: green.id,
            status: :ok,
            reason: "Green"
          }),
          DateTime.add(DateTime.utc_now(), -20, :minute)
        )

      {:ok, _} =
        time_travel(
          http_observation_fixture(%{
            http_observer_id: green.id,
            status: :failed,
            reason: "Failed but still green"
          }),
          DateTime.add(DateTime.utc_now(), -25, :hour)
        )

      {:ok, _} =
        time_travel(
          http_observation_fixture(%{
            http_observer_id: yellow.id,
            status: :failed,
            reason: "Yellow"
          }),
          DateTime.add(DateTime.utc_now(), -2, :hour)
        )

      {:ok, _} =
        time_travel(
          http_observation_fixture(%{
            http_observer_id: red.id,
            status: :failed,
            reason: "Red"
          }),
          DateTime.add(DateTime.utc_now(), -10, :minute)
        )

      assert [%{green: 1, yellow: 1, red: 1}] =
               Status.get_organizations_with_status_counts(user)
    end
  end
end
