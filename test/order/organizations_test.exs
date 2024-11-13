defmodule Order.OrganizationsTest do
  use Order.DataCase

  alias Order.Organizations

  describe "organizations" do
    alias Order.Organizations.Organization

    import Order.OrgStructureBuilder

    setup do
      user = user_fixture()
      organization = organization_fixture(%{name: "org1", owner_id: user.id})
      {:ok, user: user, organization: organization}
    end

    @invalid_attrs %{name: nil, description: nil}

    test "test the context", %{user: user, organization: organization} do
      IO.inspect(context, label: "CONTEXT")
      assert true
    end

    test "get_organization!/1 returns the organization with given id" do
      build_org_scenario(%{
        user1: %{
          owned_orgs: %{
            org1: %{
              positions: %{chair: %{}, fluffer: %{}, janitor: %{}}
            }
          },
          memberships: %{
            org1: %{
              positions: [
                %{
                  chair: {Date.new!(2024, 1, 1), nil}
                }
              ]
            }
          }
        },
        user2: %{}
      })

      organization = organization_fixture()
      assert Organizations.get_organization!(organization.id) == organization
    end

    # test "create_organization/1 with valid data creates a organization" do
    #   valid_attrs = %{name: "some name", description: "some description"}

    #   assert {:ok, %Organization{} = organization} =
    #            Organizations.create_organization(valid_attrs)

    #   assert organization.name == "some name"
    #   assert organization.description == "some description"
    # end

    # test "create_organization/1 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = Organizations.create_organization(@invalid_attrs)
    # end

    # test "update_organization/2 with valid data updates the organization" do
    #   organization = organization_fixture()
    #   update_attrs = %{name: "some updated name", description: "some updated description"}

    #   assert {:ok, %Organization{} = organization} =
    #            Organizations.update_organization(organization, update_attrs)

    #   assert organization.name == "some updated name"
    #   assert organization.description == "some updated description"
    # end

    # test "update_organization/2 with invalid data returns error changeset" do
    #   organization = organization_fixture()

    #   assert {:error, %Ecto.Changeset{}} =
    #            Organizations.update_organization(organization, @invalid_attrs)

    #   assert organization == Organizations.get_organization!(organization.id)
    # end

    # test "delete_organization/1 deletes the organization" do
    #   organization = organization_fixture()
    #   assert {:ok, %Organization{}} = Organizations.delete_organization(organization)
    #   assert_raise Ecto.NoResultsError, fn -> Organizations.get_organization!(organization.id) end
    # end

    # test "change_organization/1 returns a organization changeset" do
    #   organization = organization_fixture()
    #   assert %Ecto.Changeset{} = Organizations.change_organization(organization)
    # end
  end
end
