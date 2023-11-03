defmodule HTTPizza.Admin do
  @moduledoc """
  Defines functions to assist with admin-related operations for HTTPizza.
  """

  alias HTTPizza.Repo
  alias HTTPizza.IAM.Organization

  def create_stripe_customer(%Organization{billing_email: billing_email} = organization) do
    HTTPizza.CreateStripeCustomerWorker.new(%{
      "id" => organization.id,
      "email" => organization.billing_email,
      "name" => organization.name
    })
    |> Oban.insert()
  end

  def update_organization_billing_email(%Organization{} = organization, billing_email) do
    organization
    |> Ecto.Changeset.cast(%{billing_email: billing_email}, [:billing_email])
    |> Repo.update()
  end
end
