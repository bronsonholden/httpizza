defmodule HTTPizza.ObserversTest do
  use HTTPizza.DataCase

  alias HTTPizza.{Checks, Observers}

  describe "http_observers" do
    alias HTTPizza.Observers.HTTPObserver

    import HTTPizza.{IAMFixtures, ObserversFixtures}

    @invalid_attrs %{
      https: nil,
      port: nil,
      path: nil,
      hostname: nil,
      schedule: nil
    }

    test "list_http_observers/0 returns all http_observers" do
      %{id: id} = http_observer_fixture()
      assert [%{id: ^id}] = Observers.list_http_observers()
    end

    test "get_http_observer!/1 returns the http_observer with given id" do
      http_observer = http_observer_fixture()
      assert Observers.get_http_observer!(http_observer.id).id == http_observer.id
    end

    test "create_http_observer/1 with valid data creates a http_observer" do
      valid_attrs = %{
        https: true,
        port: 42,
        path: "/",
        hostname: "some hostname",
        schedule: "0 * * * *",
        method: :get,
        organization: organization_fixture(),
        email_recipients: [
          %{ok: true, failed: true, email: "johndoe@example.com"},
          %{ok: false, failed: false, error: true, email: "janeroe@example.com"}
        ]
      }

      assert {:ok, %HTTPObserver{} = http_observer} = Observers.create_http_observer(valid_attrs)
      assert http_observer.https == true
      assert http_observer.port == 42
      assert http_observer.path == "/"
      assert http_observer.hostname == "some hostname"
      assert http_observer.schedule == "0 * * * *"
    end

    test "create_http_observer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Observers.create_http_observer(@invalid_attrs)
    end

    test "update_http_observer/2 with valid data updates the http_observer" do
      http_observer = http_observer_fixture()

      update_attrs = %{
        https: false,
        port: 43,
        path: "images/old.png",
        hostname: "www.example.com",
        schedule: "*/5 * * * *"
      }

      assert {:ok, %HTTPObserver{} = http_observer} =
               Observers.update_http_observer(http_observer, update_attrs)

      assert http_observer.https == false
      assert http_observer.port == 43
      assert http_observer.path == "images/old.png"
      assert http_observer.hostname == "www.example.com"
      assert http_observer.schedule == "*/5 * * * *"
    end

    test "update_http_observer/2 with invalid data returns error changeset" do
      http_observer = http_observer_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Observers.update_http_observer(http_observer, @invalid_attrs)

      assert http_observer.id == Observers.get_http_observer!(http_observer.id).id
    end

    test "delete_http_observer/1 deletes the http_observer" do
      http_observer = http_observer_fixture()
      assert {:ok, %HTTPObserver{}} = Observers.delete_http_observer(http_observer)
      assert_raise Ecto.NoResultsError, fn -> Observers.get_http_observer!(http_observer.id) end
    end

    test "change_http_observer/1 returns a http_observer changeset" do
      http_observer = http_observer_fixture()
      assert %Ecto.Changeset{} = Observers.change_http_observer(http_observer)
    end
  end

  describe "http_observations" do
    alias HTTPizza.Observers.HTTPObservation

    import HTTPizza.ObserversFixtures

    @invalid_attrs %{http_observer_id: nil}

    test "list_http_observations/0 returns all http_observations" do
      http_observation = http_observation_fixture()
      assert Observers.list_http_observations() == [http_observation]
    end

    test "get_http_observation!/1 returns the http_observation with given id" do
      http_observation = http_observation_fixture()
      assert Observers.get_http_observation!(http_observation.id) == http_observation
    end

    test "create_http_observation/1 with valid data creates a http_observation" do
      http_observer = http_observer_fixture()

      valid_attrs = %{
        status: :ok,
        started_at: ~U[2023-10-05 02:42:00Z],
        duration: 42,
        http_observer_id: http_observer.id,
        check_results: [
          %{
            status: :ok,
            kind: to_string(Checks.HeaderCheck),
            reason: "Received Location: https://example.com"
          }
        ]
      }

      assert {:ok, %HTTPObservation{} = http_observation} =
               Observers.create_http_observation(valid_attrs)

      assert http_observation.status == :ok
      assert http_observation.started_at == ~U[2023-10-05 02:42:00Z]
      assert http_observation.duration == 42
    end

    test "create_http_observation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Observers.create_http_observation(@invalid_attrs)
    end

    test "update_http_observation/2 with valid data updates the http_observation" do
      http_observation = http_observation_fixture()
      update_attrs = %{status: :failed, started_at: ~U[2023-10-06 02:42:00Z], duration: 43}

      assert {:ok, %HTTPObservation{} = http_observation} =
               Observers.update_http_observation(http_observation, update_attrs)

      assert http_observation.status == :failed
      assert http_observation.started_at == ~U[2023-10-06 02:42:00Z]
      assert http_observation.duration == 43
    end

    test "update_http_observation/2 with invalid data returns error changeset" do
      http_observation = http_observation_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Observers.update_http_observation(http_observation, @invalid_attrs)

      assert http_observation == Observers.get_http_observation!(http_observation.id)
    end

    test "delete_http_observation/1 deletes the http_observation" do
      http_observation = http_observation_fixture()
      assert {:ok, %HTTPObservation{}} = Observers.delete_http_observation(http_observation)

      assert_raise Ecto.NoResultsError, fn ->
        Observers.get_http_observation!(http_observation.id)
      end
    end

    test "change_http_observation/1 returns a http_observation changeset" do
      http_observation = http_observation_fixture()
      assert %Ecto.Changeset{} = Observers.change_http_observation(http_observation)
    end
  end
end
