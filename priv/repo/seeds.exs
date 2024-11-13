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
alias Order.Positions
alias Order.Memberships
alias Order.Tenures

# Create some users
Enum.each(1..3, fn n ->
  {:ok, user} =
    Accounts.register_user(%{
      name: "Owner #{n}",
      phone: "555-555-5555",
      email: "owner@org#{n}",
      password: "password!!!!!"
    })

  {:ok, organization} =
    Organizations.create_organization(
      user,
      %{
        "name" => "Organization #{n}"
      }
    )

  Enum.each(["Chair", "Secretary", "Treasurer", "Fluffer"], fn position_name ->
    {:ok, position} = Positions.create_position(organization, %{"name" => position_name})

    {:ok, user} =
      Accounts.register_user(%{
        name: "Organization #{n} #{position_name}",
        phone: "555-555-5555",
        email: "#{String.downcase(position_name)}@org#{n}",
        password: "password!!!!!"
      })

    member_attrs = %{
      "email" => user.email,
      "active_range" => %Postgrex.Range{
        lower: Date.utc_today(),
        upper: nil,
        lower_inclusive: true,
        upper_inclusive: true
      }
    }

    {:ok, member} = Memberships.add_member(organization, member_attrs)

    {:ok, tenure} =
      Tenures.create_tenure(member, position, %{
        "active_range" => {Date.new!(2024, 1, 1), nil}
      })
  end)
end)
