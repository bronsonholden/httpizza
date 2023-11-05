defmodule HTTPizzaWeb.StripeController do
  use HTTPizzaWeb, :controller

  alias HTTPizza.{IAM, Products}

  def create(conn, %{"type" => "customer.subscription.created", "data" => data}) do
    subscription = data["object"]
    customer_id = subscription["customer"]

    organization = IAM.get_organization_by_customer_id!(customer_id)

    {:ok, _subscription} =
      Products.create_subscription(
        %{
          organization: organization
        }
        |> Enum.into(subscription_attributes(subscription))
      )

    resp(conn, 200, "OK")
  end

  def create(conn, %{"type" => "customer.subscription.updated", "data" => data}) do
    object = data["object"]
    subscription = Products.get_subscription_by_subscription_id!(object["id"])

    {:ok, _subscription} =
      Products.update_subscription(subscription, subscription_attributes(object))

    resp(conn, 200, "OK")
  end

  def create(conn, %{"type" => "customer.subscription.deleted", "data" => data}) do
    object = data["object"]
    subscription = Products.get_subscription_by_subscription_id!(object["id"])

    {:ok, _subscription} = Products.delete_subscription(subscription)

    resp(conn, 200, "OK")
  end

  def create(conn, _params) do
    resp(conn, 200, "OK")
  end

  defp subscription_attributes(subscription) do
    attrs = %{
      subscription_id: subscription["id"],
      status: subscription["status"],
      live: subscription["livemode"],
      current_period_start: DateTime.from_unix!(subscription["current_period_start"]),
      current_period_end: DateTime.from_unix!(subscription["current_period_end"])
    }

    if subscription["status"] == "active" do
      %{"plan" => %{"product" => product_id}} = subscription

      {:ok, product} = Stripe.Product.retrieve(product_id)

      case product.name do
        "Pro" ->
          Enum.into(attrs, %{
            team_member_limit: nil,
            http_observer_limit: nil,
            min_schedule_interval: 1,
            run_on_demand: true
          })

        "Plus" ->
          Enum.into(attrs, %{
            team_member_limit: 5,
            http_observer_limit: 25,
            min_schedule_interval: 5,
            run_on_demand: false
          })
      end
    else
      attrs
    end
  end
end
