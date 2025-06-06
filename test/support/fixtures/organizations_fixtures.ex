defmodule MeetingMinuet.OrganizationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MeetingMinuet.Organizations` context.
  """

  alias MeetingMinuet.Repo
  alias MeetingMinuet.Organizations.Organization

  @doc """
  Generate a organization.
  """
  def organization_fixture(user_id, attrs \\ %{}) do
    attrs = valid_organization_attributes(attrs)

    %Organization{
      owner_id: user_id
    }
    |> Organization.changeset(attrs)
    |> Repo.insert!()
  end

  def valid_organization_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: "Some org",
      description: "Some description"
    })
  end
end
