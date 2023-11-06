defmodule HTTPizzaWeb.BillingLive do
  use HTTPizzaWeb, :live_view

  alias HTTPizza.Products
  alias HTTPizzaWeb.{DashboardComponents, ProductComponents}

  import HTTPizzaWeb.Templates

  on_mount {HTTPizzaWeb.UserAuth, :ensure_authenticated}
  on_mount {HTTPizzaWeb.Organization, :ensure_organization_selected}

  @impl true
  def mount(_params, _session, socket) do
    socket =
      if socket.assigns.current_user.personal_organization == socket.assigns.current_organization do
        push_navigate(socket, to: ~p"/dashboard")
      else
        subscription =
          Products.get_organization_subscription!(socket.assigns.current_organization.id)

        socket
        |> maybe_set_subscription_details(subscription)
      end

    {:ok, socket}
  end

  defp maybe_set_subscription_details(socket, nil) do
    socket
    |> assign(:subscription, nil)
    |> assign(:upcoming_invoice, nil)
  end

  defp maybe_set_subscription_details(socket, subscription) do
    {:ok, sub} =
      Stripe.Subscription.retrieve(
        subscription.subscription_id,
        %{expand: ["items.data.plan.product"]}
      )

    [%{plan: plan}] = sub.items.data

    socket =
      socket
      |> assign(
        :subscription,
        subscription
      )
      |> assign(:will_expire, sub.cancel_at_period_end)
      |> assign(:plan, plan.product.name)
      |> assign(:interval, plan.interval)
      |> assign(:amount, plan.amount)

    socket =
      if sub.cancel_at_period_end do
        socket
      else
        {:ok, invoice} = Stripe.Invoice.upcoming(%{subscription: subscription.subscription_id})

        assign(socket, :upcoming_invoice, invoice)
      end

    socket
  end

  @impl true
  def handle_params(_params, uri, socket) do
    {:noreply, assign(socket, :current_uri, uri)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.dashboard
      current_uri={@current_uri}
      organizations_with_status_counts={
        HTTPizza.Status.get_organizations_with_status_counts(@current_user)
      }
      personal_organization={@current_user.personal_organization}
      current_organization={@current_organization}
      slug={@current_organization_slug}
      path="/billing"
    >
      <DashboardComponents.breadcrumbs
        organization={@current_organization}
        slug={@current_organization_slug}
        title="Billing"
      />

      <%= if @subscription do %>
        <h1 class="text-2xl font-bold my-4">
          Thanks for being a subscriber
        </h1>
        <div class="rounded bg-stone-200/60 dark:bg-stone-700/60 p-4 space-y-6">
          <div>
            <h2 class="font-medium text-stone-600 dark:text-stone-400">
              Your plan
            </h2>
            <p class="font-bold">
              <%= @plan %> at $<%= display_price(@amount) %> per <%= @interval %>
            </p>
          </div>

          <ProductComponents.plan_feature_list plan={String.downcase(@plan)} />

          <div :if={@will_expire}>
            <h2 class="font-medium text-stone-600 dark:text-stone-400">
              Expires
            </h2>

            <p>
              <%= formatted_time(@subscription.current_period_end) %>
            </p>
          </div>

          <button
            :if={not @will_expire}
            class="p-2 bg-red-500 text-white opacity-80 hover:opacity-100 rounded"
            phx-click="cancel_subscription"
          >
            Cancel renewal
          </button>

          <button
            :if={@will_expire}
            class="p-2 bg-stone-500 text-white opacity-80 hover:opacity-100 rounded"
            phx-click="keep_subscription"
          >
            Keep my plan
          </button>
        </div>

        <div :if={not @will_expire} class="my-6">
          <h2 class="text-lg font-bold">Upcoming payment</h2>

          <p class="text-stone-600 dark:text-stone-400">
            <%= DateTime.from_unix!(@upcoming_invoice.created)
            |> Timex.format!("{Mshort} {D}, {YYYY}") %>
          </p>

          <table class="my-4 w-full border border-stone-200 dark:border-stone-600">
            <thead>
              <tr>
                <th class="border border-stone-200 dark:border-stone-600 py-2 px-4">
                  Description
                </th>
                <th class="border border-stone-200 dark:border-stone-600 py-2 px-4">
                  Amount
                </th>
              </tr>
            </thead>
            <tbody :for={line <- @upcoming_invoice.lines.data}>
              <tr>
                <td class="border border-stone-200 dark:border-stone-600 py-2 px-4">
                  <%= line.description %>
                </td>
                <td class="border border-stone-200 dark:border-stone-600 py-2 px-4 font-mono text-right">
                  $<%= display_price(line.amount_excluding_tax) %>
                </td>
              </tr>
              <tr :for={discount <- line.discount_amounts}>
                <td class="border border-stone-200 dark:border-stone-600 py-2 px-4">Discount</td>
                <td class="border border-stone-200 dark:border-stone-600 py-2 px-4 font-mono text-right">
                  -$<%= display_price(discount.amount) %>
                </td>
              </tr>
            </tbody>
            <tbody>
              <tr>
                <td class="px-4 py-2">
                  Total
                </td>
                <td class="text-right px-4 py-2 font-mono">
                  $<%= display_price(@upcoming_invoice.total_excluding_tax) %>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      <% else %>
        <h1 class="text-2xl font-bold my-4">
          Select a plan to subscribe
        </h1>

        <div class="rounded-lg border border-stone-200 dark:border-stone-700 p-4 my-4">
          <h2 class="text-lg font-bold">Free</h2>
          <hr class="border-stone-300 dark:border-stone-600 mt-1 mb-3" />
          <ProductComponents.plan_feature_list plan="free" />
        </div>

        <div class="rounded-lg bg-stone-200 dark:bg-stone-700 p-4 my-4">
          <h2 class="text-lg font-bold">Plus — $100 per year</h2>
          <hr class="border-stone-300 dark:border-stone-600 mt-1 mb-3" />
          <ProductComponents.plan_feature_list plan="plus" />
          <.link
            navigate={
              ~p"/dashboard/#{@current_organization_slug}/checkout?#{[plan: "plus", interval: "year"]}"
            }
            class="font-medium inline-block mt-4 gap-2 rounded py-2 px-4 bg-orange-500 text-white"
          >
            Select
          </.link>
        </div>

        <div class="rounded-lg bg-stone-200 dark:bg-stone-700 p-4 my-4">
          <h2 class="text-lg font-bold">Pro — $300 per year</h2>
          <hr class="border-stone-300 dark:border-stone-600 mt-1 mb-3" />
          <ProductComponents.plan_feature_list plan="pro" />
          <.link
            navigate={
              ~p"/dashboard/#{@current_organization_slug}/checkout?#{[plan: "pro", interval: "year"]}"
            }
            class="font-medium inline-block mt-4 gap-2 rounded py-2 px-4 bg-orange-500 text-white"
          >
            Select
          </.link>
        </div>
      <% end %>
    </.dashboard>
    """
  end

  attr(:slug, :string, required: true)

  defp plan_cards(assigns) do
    ~H"""
    <div class="flex gap-4 justify-center w-full my-8">
      <.link
        navigate={~p"/dashboard/#{@slug}/checkout?#{[interval: "year", plan: "plus"]}"}
        class="grow text-center px-6 py-4 opacity-60 hover:opacity-100 block rounded border-stone-500 dark:border-stone-600 bg-stone-200 dark:bg-stone-700 border"
      >
        <p class="text-2xl font-bold">
          Buy
          <span class="bg-gradient-to-r bg-clip-text text-transparent from-blue-400 to-green-600">
            Plus
          </span>
        </p>

        <ul class="text-sm">
          <li>It's awesome</li>
          <li>You're awesome</li>
          <li>We're awesome together</li>
        </ul>
      </.link>
      <.link
        navigate={~p"/dashboard/#{@slug}/checkout?#{[interval: "year", plan: "pro"]}"}
        class="grow text-center px-6 py-4 opacity-60 hover:opacity-100 block rounded border-stone-500 dark:border-stone-600 bg-stone-200 dark:bg-stone-700 border"
      >
        <p class="text-2xl font-bold">
          Buy
          <span class="bg-gradient-to-r bg-clip-text text-transparent from-indigo-400 to-orange-400">
            Pro
          </span>
        </p>

        <ul class="text-sm">
          <li>It's awesome</li>
          <li>You're awesome</li>
          <li>We're awesome together</li>
        </ul>
      </.link>
    </div>
    """
  end

  @spec display_price(pos_integer()) :: String.t()
  defp display_price(price) do
    (price / 100)
    |> Decimal.from_float()
    |> Decimal.round(2)
    |> Decimal.to_string(:normal)
  end

  @impl true
  def handle_event("cancel_subscription", _params, socket) do
    {:ok, _subscription} =
      Stripe.Subscription.update(socket.assigns.subscription.subscription_id, %{
        cancel_at_period_end: true
      })

    socket =
      socket
      |> put_flash(
        :info,
        "Your subscription is canceled. You can enjoy your #{socket.assigns.plan} plan until it expires on #{formatted_time(socket.assigns.subscription.current_period_end)}."
      )
      |> push_navigate(to: ~p"/dashboard/#{socket.assigns.current_organization_slug}/billing")

    {:noreply, socket}
  end

  @impl true
  def handle_event("keep_subscription", _params, socket) do
    {:ok, _} =
      Stripe.Subscription.update(socket.assigns.subscription.subscription_id, %{
        cancel_at_period_end: false
      })

    socket =
      socket
      |> put_flash(
        :info,
        "Your subscription is reactivated. It will renew on #{formatted_time(socket.assigns.subscription.current_period_end)}."
      )
      |> push_navigate(to: ~p"/dashboard/#{socket.assigns.current_organization_slug}/billing")

    {:noreply, socket}
  end

  def formatted_time(timestamp) do
    Timex.format!(timestamp, "{Mshort} {D}, {YYYY}")
  end
end
