# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Order.Repo.insert!(%Order.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Order.Organizations
alias Order.Accounts

# Create some users
Enum.each(1..3, fn n ->
  {:ok, user} =
    Accounts.register_user(%{
      email: "owner@org#{n}",
      password: "password!!!!!",
      first_name: "Owner",
      last_name: "Org#{n}",
      phone_number: "123-456-7890"
    })

  {:ok, organization} =
    Organizations.create_organization(
      %{
        "name" => "Organization #{n}"
      },
      user
    )

  Enum.each(["Chair", "Secretary", "Treasurer", "Fluffer"], fn name ->
    {:ok, position} = Organizations.create_position(organization, %{"name" => name})

    {:ok, member} =
      Accounts.register_user(%{
        email: "#{String.downcase(name)}@org#{n}",
        password: "password!!!!!",
        first_name: "Org#{n}",
        last_name: name,
        phone_number: "123-456-7890"
      })

    {:ok, member} = Organizations.add_member(organization, position, member)
  end)
end)
