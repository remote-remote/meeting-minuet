defmodule Order.OrganizationsTest do
  use Order.DataCase

  import Order.ContextBuilder
  alias Order.Organizations.Organization
  alias Order.Organizations

  describe "organizations" do
    setup do
      context =
        build_context(%{
          users: %{
            user1: %{},
            user2: %{}
          },
          orgs: %{
            org1: %{
              owner: :user1
            },
            org2: %{
              owner: :user1
            },
            org3: %{
              owner: :user1
            },
            org4: %{
              owner: :user2
            },
            org5: %{
              owner: :user2
            }
          }
        })

      {:ok, context}
    end

    @invalid_attrs %{name: nil, description: nil}

    test "get_organization!/1 returns the organization with given id", context do
      organization = get_org(context, :org1)
      assert Organizations.get_organization!(organization.id) == organization
    end

    test "create_organization/1 with valid data creates a organization", context do
      user = get_user(context, :user1)

      valid_attrs = %{
        name: "some name",
        description: "some description",
        owner_id: user.id
      }

      assert {:ok, %Organization{} = organization} =
               Organizations.create_organization(valid_attrs)

      assert organization.name == "some name"
      assert organization.description == "some description"
      assert organization.owner_id == user.id
    end

    test "create_organization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organizations.create_organization(@invalid_attrs)
    end

    test "update_organization/2 with valid data updates the organization", context do
      update_attrs = %{name: "some updated name", description: "some updated description"}
      organization = get_org(context, :org1)

      assert {:ok, %Organization{} = organization} =
               Organizations.update_organization(organization, update_attrs)

      assert organization == Organizations.get_organization!(organization.id)
      assert organization.name == "some updated name"
      assert organization.description == "some updated description"
    end

    test "update_organization/2 with invalid data returns error changeset", context do
      organization = get_org(context, :org1)

      assert {:error, %Ecto.Changeset{}} =
               Organizations.update_organization(organization, @invalid_attrs)

      assert organization == Organizations.get_organization!(organization.id)
    end

    test "delete_organization/1 deletes the organization", context do
      organization = get_org(context, :org1)
      assert {:ok, %Organization{}} = Organizations.delete_organization(organization)
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_organization!(organization.id) end
    end

    test "change_organization/1 returns a organization changeset", context do
      organization = get_org(context, :org1)
      assert %Ecto.Changeset{} = Organizations.change_organization(organization)
    end
  end
end
