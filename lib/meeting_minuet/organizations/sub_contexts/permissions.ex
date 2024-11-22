defmodule MeetingMinuet.Organizations.Permissions do
  import MeetingMinuet.Organizations.Permission

  permission(:edit_organization, [:admin])
  permission(:delete_organization, [:admin])
  permission(:create_meetings, [:admin])
  permission(:delete_meetings, [:admin])
  permission(:edit_meetings, [:admin])
  permission(:add_members, [:admin])
  permission(:delete_members, [:admin])
  permission(:create_positions, [:admin])
  permission(:assign_positions, [:admin])
  permission(:edit_positions, [:admin])
  permission(:delete_positions, [:admin])
end
