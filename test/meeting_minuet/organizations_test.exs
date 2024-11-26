defmodule MeetingMinuet.OrganizationsTest do
  use MeetingMinuet.DataCase

  import MeetingMinuet.ContextBuilder
  alias MeetingMinuet.Organizations.Organization
  alias MeetingMinuet.Organizations

  describe "organizations crud" do
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
    test "get_organization!/1 returns the organization", context do
      organization = get_org(context, :org1)

      assert Organizations.get_organization!(organization.id).id == organization.id
    end

    test "get_organization!/2 returns the organization for owner", context do
      organization = get_org(context, :org1)
      owner = get_user(context, :user1)
      assert Organizations.get_organization!(owner, organization.id).id == organization.id
    end

    test "get_organization!/2 returns nil for non-owner", context do
      organization = get_org(context, :org1)
      non_owner = get_user(context, :user2)

      assert_raise Ecto.NoResultsError,
                   fn ->
                     Organizations.get_organization!(non_owner, organization.id).id ==
                       organization.id
                   end
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

      found_org = Organizations.get_organization!(organization.id)
      assert found_org.name == "some updated name"
      assert found_org.description == "some updated description"
    end

    test "update_organization/2 with invalid data returns error changeset", context do
      organization = get_org(context, :org1)

      assert {:error, %Ecto.Changeset{}} =
               Organizations.update_organization(organization, @invalid_attrs)

      assert organization |> Repo.preload(:memberships) ==
               Organizations.get_organization!(organization.id)
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

  describe "organization memberships" do
    setup do
      context =
        build_context(%{
          users: %{
            user1: %{},
            user2: %{},
            user3: %{}
          },
          orgs: %{
            org1: %{
              owner: :user1,
              memberships: %{
                user1: {~D[2024-01-01], nil},
                user2: {~D[2024-01-01], nil}
              },
              positions: %{
                chair: %{
                  user1: {~D[2023-01-01], ~D[2023-12-31]},
                  user2: {~D[2024-01-01], nil}
                },
                secretary: %{
                  user1: {~D[2024-01-01], nil},
                  user2: {~D[2023-01-01], ~D[2023-12-31]}
                }
              }
            },
            org2: %{
              owner: :user2,
              memberships: %{
                user3: {~D[2024-01-01], nil}
              },
              positions: %{
                chair: %{
                  user3: {~D[2023-01-01], ~D[2023-12-31]}
                },
                secretary: %{
                  user3: {~D[2024-01-01], nil}
                }
              }
            }
          }
        })

      {:ok, context}
    end

    @tag run: true
    test "list_members/1 returns organization_members in the correct shape", context do
      organization = get_org(context, :org1)
      members = Organizations.list_members(organization.id)
      assert length(members) == 2
      assert Enum.at(members, 0).user_id == get_user(context, :user1).id
      assert Enum.at(members, 1).user_id == get_user(context, :user2).id
    end
  end
end
