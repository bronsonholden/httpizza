defmodule HTTPizza.ProductsTest do
  use HTTPizza.DataCase

  alias HTTPizza.Products

  describe "subscriptions" do
    alias HTTPizza.Products.Subscription

    import HTTPizza.ProductsFixtures

    @invalid_attrs %{
      status: :nothing
    }

    test "list_subscriptions/0 returns all subscriptions" do
      subscription = subscription_fixture()

      assert Products.list_subscriptions() |> HTTPizza.Repo.preload(:organization) == [
               subscription
             ]
    end

    test "get_subscription!/1 returns the subscription with given id" do
      subscription = subscription_fixture()

      assert Products.get_subscription!(subscription.id) |> HTTPizza.Repo.preload(:organization) ==
               subscription
    end

    test "create_subscription/1 with valid data creates a subscription" do
      valid_attrs = %{
        status: :active,
        live: true,
        current_period_start: ~U[2023-11-03 02:01:00Z],
        current_period_end: ~U[2023-11-03 02:01:00Z],
        http_observer_limit: 42,
        team_member_limit: 42,
        min_schedule_interval: 42,
        run_on_demand: true
      }

      assert {:ok, %Subscription{} = subscription} = Products.create_subscription(valid_attrs)
      assert subscription.status == :active
      assert subscription.live == true
      assert subscription.current_period_start == ~U[2023-11-03 02:01:00Z]
      assert subscription.current_period_end == ~U[2023-11-03 02:01:00Z]
      assert subscription.http_observer_limit == 42
      assert subscription.team_member_limit == 42
      assert subscription.min_schedule_interval == 42
      assert subscription.run_on_demand == true
    end

    test "create_subscription/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_subscription(@invalid_attrs)
    end

    test "update_subscription/2 with valid data updates the subscription" do
      subscription = subscription_fixture()

      update_attrs = %{
        http_observer_limit: 10,
        team_member_limit: 10
      }

      assert {:ok, %Subscription{} = subscription} =
               Products.update_subscription(subscription, update_attrs)

      assert subscription.http_observer_limit == 10
      assert subscription.team_member_limit == 10
    end

    test "update_subscription/2 with invalid data returns error changeset" do
      subscription = subscription_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Products.update_subscription(subscription, @invalid_attrs)

      assert subscription ==
               Products.get_subscription!(subscription.id) |> HTTPizza.Repo.preload(:organization)
    end

    test "delete_subscription/1 deletes the subscription" do
      subscription = subscription_fixture()
      assert {:ok, %Subscription{}} = Products.delete_subscription(subscription)
      assert_raise Ecto.NoResultsError, fn -> Products.get_subscription!(subscription.id) end
    end

    test "change_subscription/1 returns a subscription changeset" do
      subscription = subscription_fixture()
      assert %Ecto.Changeset{} = Products.change_subscription(subscription)
    end
  end
end
