defmodule HTTPizza.Admin do
  @moduledoc """
  Defines functions to assist with admin-related operations for HTTPizza.
  """

  alias HTTPizza.IAM.Organization

  def create_stripe_customer(%Organization{billing_email: billing_email} = organization)
      when not is_binary(billing_email) do
    HTTPizza.CreateStripeCustomerWorker.new(%{
      "id" => organization.id,
      "email" => organization.billing_email,
      "name" => organization.name
    })
    |> Oban.insert()
  end
end
