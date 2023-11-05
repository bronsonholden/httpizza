defmodule HTTPizzaWeb.AdminLive do
  use HTTPizzaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:organizations, HTTPizza.IAM.list_organizations())
      |> assign(
        :subscriptions,
        HTTPizza.Products.list_subscriptions() |> HTTPizza.Repo.preload(:organization)
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-4">
      <h2 class="text-lg font-bold">Organizations</h2>
      <table class="my-2 w-full">
        <thead>
          <tr>
            <th class="border text-left p-2">Name</th>
            <th class="border text-left p-2">Slug</th>
            <th class="border text-left p-2">Billing email</th>
            <th class="border text-left p-2">Customer ID</th>
          </tr>
        </thead>
        <tr :for={organization <- @organizations}>
          <td class="border p-2"><%= organization.name %></td>
          <td class="border p-2"><%= organization.slug %></td>
          <td class="border p-2"><%= organization.billing_email %></td>
          <td class="border p-2"><%= organization.customer_id %></td>
        </tr>
      </table>

      <h2 class="text-lg font-bold mt-8">Subscriptions</h2>
      <table class="my-2 w-full">
        <thead>
          <tr>
            <th class="border text-left p-2">Subscription ID</th>
            <th class="border text-left p-2">Status</th>
            <th class="border text-left p-2">Customer ID</th>
            <th class="border text-left p-2">Organization</th>
            <th class="border text-left p-2">HTTP Observer Limit</th>
            <th class="border text-left p-2">Team Member Limit</th>
            <th class="border text-left p-2">Minimum schedule interval</th>
            <th class="border text-left p-2">Run on demand</th>
          </tr>
        </thead>
        <tr :for={subscription <- @subscriptions}>
          <td class="border p-2"><%= subscription.subscription_id %></td>
          <td class="border p-2"><%= subscription.status %></td>
          <td class="border p-2"><%= subscription.organization.customer_id %></td>
          <td class="border p-2"><%= subscription.organization.name %></td>
          <td class="border p-2"><%= subscription.http_observer_limit %></td>
          <td class="border p-2"><%= subscription.team_member_limit %></td>
          <td class="border p-2"><%= subscription.min_schedule_interval %></td>
          <td class="border p-2"><%= subscription.run_on_demand %></td>
        </tr>
      </table>
    </div>
    """
  end
end
