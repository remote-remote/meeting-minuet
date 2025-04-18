defmodule MeetingMinuet.Organizations do
  @moduledoc """
  The Organizations context.
  """

  import Ecto.Query, warn: false
  alias MeetingMinuet.Organizations.{Members, Positions, Organizations}

  # Members
  defdelegate list_members(organization), to: Members
  defdelegate get_membership(organization, user), to: Members
  defdelegate get_member!(membership_id), to: Members
  defdelegate get_member!(organization, user), to: Members
  defdelegate invite_member(organization, url_fn, attrs), to: Members
  defdelegate is_member?(organization, user), to: Members

  # Positions (maybe don't need all this?)
  defdelegate list_positions(organization), to: Positions
  defdelegate get_position!(organization, position_id), to: Positions
  defdelegate create_position(organization, attrs), to: Positions
  defdelegate change_position(position, attrs \\ %{}), to: Positions
  defdelegate update_position(position, attrs), to: Positions
  defdelegate create_tenure(attrs), to: Positions
  defdelegate get_tenure!(org, tenure_id), to: Positions
  defdelegate tenures_overlap?(proposed_tenure), to: Positions
  defdelegate update_tenure(tenure, attrs), to: Positions

  defdelegate list_organizations(user), to: Organizations
  defdelegate get_organization!(organization_id), to: Organizations
  defdelegate get_organization!(user, organization_id), to: Organizations
  defdelegate get_fully_preloaded_organization!(user, organization_id), to: Organizations
  defdelegate create_organization(attrs), to: Organizations
  defdelegate create_organization(attrs, user), to: Organizations
  defdelegate update_organization(organization, attrs), to: Organizations
  defdelegate delete_organization(organization), to: Organizations
  defdelegate change_organization(organization, attrs \\ %{}), to: Organizations
end
