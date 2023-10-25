defmodule HTTPizza.CreateStripeCustomerWorker do
  use Oban.Worker, queue: :default, unique: [period: 60, fields: [:args, :worker]]

  alias HTTPizza.IAM

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id, "email" => email, "name" => name}}) do
    organization = IAM.get_organization!(id)

    {:ok, customer} =
      Stripe.Customer.create(%{
        email: email,
        name: name
      })

    IAM.update_organization(organization, %{customer_id: customer.id})
  end
end
