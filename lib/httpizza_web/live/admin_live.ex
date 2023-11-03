defmodule HTTPizzaWeb.AdminLive do
  use HTTPizzaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:organizations, HTTPizza.IAM.list_organizations())

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
            <th class="border text-left p-2">Customer ID</th>
          </tr>
        </thead>
        <tr :for={organization <- @organizations}>
          <td class="border p-2"><%= organization.name %></td>
          <td class="border p-2"><%= organization.slug %></td>
          <td class="border p-2"><%= organization.customer_id %></td>
        </tr>
      </table>
    </div>
    """
  end
end
