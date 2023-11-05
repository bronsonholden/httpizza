defmodule HTTPizzaWeb.CheckoutLive do
  use HTTPizzaWeb, :live_view

  alias HTTPizzaWeb.ProductComponents

  on_mount {HTTPizzaWeb.UserAuth, :ensure_authenticated}
  on_mount {HTTPizzaWeb.Organization, :ensure_organization_selected}

  @impl true
  def mount(_params, _session, socket) do
    socket =
      if socket.assigns.current_user.personal_organization == socket.assigns.current_organization do
        socket
        |> push_navigate(to: ~p"/dashboard")
        |> put_flash(:error, "You cannot purchase subscriptions for your personal organization.")
      else
        socket
      end

    socket =
      if HTTPizza.Products.get_organization_subscription!(socket.assigns.current_organization.id) do
        socket
        |> push_navigate(to: ~p"/dashboard/#{socket.assigns.current_organization_slug}/billing")
        |> put_flash(:error, "You already have an active subscription.")
      else
        socket
      end

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"plan" => plan, "interval" => interval}, uri, socket) do
    {:ok, prices} =
      Stripe.Price.list(%{
        active: true,
        recurring: %{interval: interval},
        expand: ["data.product"]
      })

    price =
      Enum.find(prices.data, fn %{product: product} -> String.downcase(product.name) == plan end)

    socket =
      if price do
        socket
        |> assign(:price, price)
        |> assign(:plan, plan)
        |> assign(:interval, interval)
        |> assign(:current_uri, uri)
        |> assign(:client_secret, nil)
        |> create_incomplete_subscription()
      else
        socket
        |> put_flash(:error, "We're having issues with checkout. Please try again later.")
        |> push_navigate(to: "/dashboard/#{socket.assigns.current_organization_slug}")
      end

    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply,
     push_navigate(socket,
       to:
         ~p"/dashboard/#{socket.assigns.current_organization_slug}/checkout?#{[plan: "plus", interval: "year"]}"
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-xl mx-auto sm:my-8 p-4">
      <div class="space-y-4">
        <h1 class="font-bold text-3xl">
          Subscribe to <%= @price.product.name %> for $<%= display_price(@price.unit_amount) %> per <%= @price.recurring.interval %>
        </h1>
        <div class="my-4">
          <ProductComponents.plan_feature_list plan={@plan} />
        </div>
        <.swap_interval slug={@current_organization_slug} plan={@plan} interval={@interval} />
      </div>
      <form id="payment-form" phx-submit="confirm_payment" class="my-4">
        <div
          phx-hook="Checkout"
          class="peer"
          id="checkout"
          data-return-url={
            Enum.join([
              if(System.get_env("PHX_HOST"), do: "https", else: "http"),
              "://",
              System.get_env("PHX_HOST", "localhost:4000"),
              ~p"/dashboard/#{@current_organization_slug}"
            ])
          }
          data-stripe-key={System.get_env("STRIPE_PUBLISHABLE_KEY")}
          data-client-secret={@client_secret}
        />
        <button
          class="hidden peer-[.ready]:block p-2 bg-green-500 text-white font-medium my-8 rounded"
          type="submit"
        >
          Subscribe
        </button>
      </form>
    </div>
    """
  end

  defp create_incomplete_subscription(socket) do
    {:ok, subscription} =
      Stripe.Subscription.create(%{
        customer: socket.assigns.current_organization.customer_id,
        items: [
          %{
            # TEST MODE: Plus yearly. TODO
            price: socket.assigns.price.id
          }
        ],
        payment_behavior: :default_incomplete,
        expand: ["latest_invoice.payment_intent"]
      })

    socket
    |> assign(:subscription, subscription)
    |> assign(:payment_intent, subscription.latest_invoice.payment_intent)
    |> assign(:client_secret, subscription.latest_invoice.payment_intent.client_secret)
  end

  @impl true
  def handle_event("confirm_payment", _params, socket) do
    {:noreply, push_event(socket, "confirm-payment", %{})}
  end

  @spec display_price(pos_integer()) :: String.t()
  defp display_price(price) do
    (price / 100)
    |> Decimal.from_float()
    |> Decimal.round(2)
    |> Decimal.to_string(:normal)
  end

  attr(:slug, :string, required: true)
  attr(:interval, :string, required: true, values: ["month", "year"])
  attr(:plan, :string, required: true, values: ["plus", "pro"])

  defp swap_interval(%{interval: "year"} = assigns) do
    ~H"""
    <.link_to_interval plan={@plan} interval="month" slug={@slug} />
    """
  end

  defp swap_interval(%{interval: "month"} = assigns) do
    ~H"""
    <.link_to_interval plan={@plan} interval="year" slug={@slug} />
    """
  end

  defp link_to_interval(assigns) do
    ~H"""
    <.link
      navigate={~p"/dashboard/#{@slug}/checkout?#{[plan: @plan, interval: @interval]}"}
      class="my-2 font-medium text-stone-600 dark:text-stone-400 hover:text-stone-900 dark:hover:text-stone-50 flex items-center gap-1"
    >
      Switch to <%= @interval %>ly billing <.icon name="hero-arrow-right" class="scale-75" />
    </.link>
    """
  end
end
