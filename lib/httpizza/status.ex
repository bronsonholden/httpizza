defmodule HTTPizza.Status do
  @moduledoc """
  Higher-level context for organization and observer queries.
  """

  alias HTTPizza.Repo
  alias HTTPizza.Observers.{HTTPObserver, HTTPObservation}
  alias HTTPizza.IAM.{Organization, OrganizationUser, User}

  import Ecto.Query

  @spec get_organizations_with_status_counts(%User{}) ::
          [
            %{
              organization: %HTTPizza.IAM.Organization{},
              red: non_neg_integer(),
              yellow: non_neg_integer(),
              green: non_neg_integer()
            }
          ]
  def get_organizations_with_status_counts(%User{} = user) do
    user_id = user.id
    one_hour_ago = DateTime.add(DateTime.utc_now(), -1, :hour)
    one_day_ago = DateTime.add(DateTime.utc_now(), -1, :day)

    red =
      from(h in HTTPObserver,
        left_join: o in HTTPObservation,
        on: h.id == o.http_observer_id,
        where: o.status == :failed and o.inserted_at > ^one_hour_ago and not o.resolved,
        distinct: h.id,
        select: h.id
      )

    yellow =
      from(h in HTTPObserver,
        left_join: o in HTTPObservation,
        on: h.id == o.http_observer_id,
        where:
          o.status == :failed and o.inserted_at > ^one_day_ago and h.id not in subquery(red) and
            not o.resolved,
        distinct: h.id,
        select: h.id
      )

    green =
      from(h in HTTPObserver,
        where: h.id not in subquery(yellow) and h.id not in subquery(red),
        distinct: h.id,
        select: h.id
      )

    from(
      o in Organization,
      join: u in OrganizationUser,
      on: u.organization_id == o.id and u.user_id == ^user_id,
      left_join: h in HTTPObserver,
      on: h.organization_id == o.id,
      left_join: red in subquery(red),
      on: h.id == red.id,
      left_join: yellow in subquery(yellow),
      on: h.id == yellow.id,
      left_join: green in subquery(green),
      on: h.id == green.id,
      group_by: [o.id, o.slug, u.personal],
      order_by: [desc_nulls_last: u.personal, asc: o.name],
      select: %{
        organization: o,
        red: fragment("count(?)", red.id),
        yellow: fragment("count(?)", yellow.id),
        green: fragment("count(?)", green.id)
      }
    )
    |> Repo.all()
  end
end
