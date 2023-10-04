defmodule HTTPizza.ObserversTest do
  use HTTPizza.DataCase

  alias HTTPizza.Observers

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
        path: ["option1", "option2"],
        hostname: "some hostname",
        schedule: "0 * * * *",
        method: :get,
        organization: organization_fixture()
      }

      assert {:ok, %HTTPObserver{} = http_observer} = Observers.create_http_observer(valid_attrs)
      assert http_observer.https == true
      assert http_observer.port == 42
      assert http_observer.path == ["option1", "option2"]
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
        path: ["images", "old.png"],
        hostname: "www.example.com",
        schedule: "*/5 * * * *"
      }

      assert {:ok, %HTTPObserver{} = http_observer} =
               Observers.update_http_observer(http_observer, update_attrs)

      assert http_observer.https == false
      assert http_observer.port == 43
      assert http_observer.path == ["images", "old.png"]
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
end
