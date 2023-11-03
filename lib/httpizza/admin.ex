defmodule HTTPizza.Admin do
  @moduledoc """
  Defines functions to assist with admin-related operations for HTTPizza.
  """

  alias HTTPizza.Repo
  alias HTTPizza.IAM.Organization

  def create_stripe_customer(%Organization{} = organization) do
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

  @doc """
  Set `admin` to `true` for the given user by email.
  """
  def promote_user_by_email(email) do
    email
    |> HTTPizza.IAM.get_user_by_email()
    |> Ecto.Changeset.cast(%{admin: true}, [:admin])
    |> Repo.update()
  end

  @doc """
  Set `admin` to `false` for the given user by email.
  """
  def demote_user_by_email(email) do
    email
    |> HTTPizza.IAM.get_user_by_email()
    |> Ecto.Changeset.cast(%{admin: false}, [:admin])
    |> Repo.update()
  end
end
