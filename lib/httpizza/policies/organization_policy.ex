defmodule HTTPizza.OrganizationPolicy do
  alias HTTPizza.{IAM, Products}

  @default_team_member_limit 2

  def authorize(action, _user, _org, organization \\ nil)

  def authorize("invite_user", _user, organization, nil) do
    members = IAM.count_organization_users(organization.id)
    limit = team_member_limit(organization)

    if is_nil(limit) or members < limit do
      :ok
    else
      {:unauthorized, "You have reached the team member limit of #{limit}."}
    end
  end

  defp team_member_limit(organization) do
    case Products.get_organization_subscription!(organization.id) do
      nil -> @default_team_member_limit
      subscription -> subscription.team_member_limit
    end
  end
end
