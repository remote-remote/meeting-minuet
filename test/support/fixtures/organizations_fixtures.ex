defmodule Order.OrganizationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Order.Organizations` context.
  """

  alias Order.Repo
  alias Order.Organizations.Organization
  alias Order.Accounts.User

  @doc """
  Generate a organization.
  """
  def organization_fixture(org_attrs \\ %{}) do
    %Organization{}
    |> Organization.changeset(org_attrs)
    |> Repo.insert!()
  end
end
