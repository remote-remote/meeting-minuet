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

import Order.ContextBuilder

build_context(%{
  users: %{
    jimbo_slooze: %{
      name: "Jimbo Slooze"
    },
    fizzle_poppleton: %{
      name: "Fizzle Poppleton"
    },
    bubbles_mcfizzle: %{
      name: "Bubbles McFizzle"
    },
    misty_fuddlewump: %{
      name: "Misty Fuddlewump"
    },
    sassy_mcsnazzle: %{
      name: "Sassy McSnazzle"
    },
    rufus_dingleberry: %{
      name: "Rufus Dingleberry"
    }
  },
  orgs: %{
    flibber_fanatics: %{
      name: "Flibber Fanatics",
      owner: :jimbo_slooze,
      memberships: %{
        jimbo_slooze: {nil, nil},
        bubbles_mcfizzle: {nil, nil},
        fizzle_poppleton: {nil, nil},
        misty_fuddlewump: {nil, nil},
        sassy_mcsnazzle: {nil, nil},
        # Member without a position
        rufus_dingleberry: {nil, nil}
      },
      positions: %{
        chair: %{
          jimbo_slooze: {Date.new!(2023, 1, 1), Date.new!(2023, 12, 31)},
          bubbles_mcfizzle: {Date.new!(2024, 1, 1), nil}
        },
        co_chair: %{
          fizzle_poppleton: {Date.new!(2023, 1, 1), nil}
        },
        secretary: %{
          misty_fuddlewump: {Date.new!(2023, 1, 1), nil}
        },
        treasurer: %{
          sassy_mcsnazzle: {Date.new!(2023, 1, 1), nil}
        },
        admin: %{
          bubbles_mcfizzle: {Date.new!(2023, 1, 1), Date.new!(2023, 6, 30)},
          jimbo_slooze: {Date.new!(2023, 7, 1), nil}
        }
      }
    },
    wiggle_wizards: %{
      name: "Wiggle Wizards",
      owner: :fizzle_poppleton,
      memberships: %{
        fizzle_poppleton: {nil, nil},
        jimbo_slooze: {nil, nil},
        sassy_mcsnazzle: {nil, nil},
        bubbles_mcfizzle: {nil, nil},
        misty_fuddlewump: {nil, nil},
        # Member without a position
        rufus_dingleberry: {nil, nil}
      },
      positions: %{
        chair: %{
          fizzle_poppleton: {Date.new!(2023, 1, 1), Date.new!(2023, 12, 31)},
          jimbo_slooze: {Date.new!(2024, 1, 1), nil}
        },
        co_chair: %{
          sassy_mcsnazzle: {Date.new!(2023, 1, 1), nil}
        },
        secretary: %{
          bubbles_mcfizzle: {Date.new!(2023, 1, 1), nil}
        },
        treasurer: %{
          misty_fuddlewump: {Date.new!(2023, 1, 1), nil}
        },
        admin: %{
          jimbo_slooze: {Date.new!(2023, 1, 1), Date.new!(2023, 6, 30)},
          sassy_mcsnazzle: {Date.new!(2023, 7, 1), nil}
        }
      }
    },
    snicker_snappers: %{
      name: "Snicker Snappers",
      owner: :bubbles_mcfizzle,
      memberships: %{
        bubbles_mcfizzle: {nil, nil},
        misty_fuddlewump: {nil, nil},
        jimbo_slooze: {nil, nil},
        sassy_mcsnazzle: {nil, nil},
        fizzle_poppleton: {nil, nil},
        # Member without a position
        rufus_dingleberry: {nil, nil}
      },
      positions: %{
        chair: %{
          bubbles_mcfizzle: {Date.new!(2023, 1, 1), Date.new!(2023, 12, 31)},
          misty_fuddlewump: {Date.new!(2024, 1, 1), nil}
        },
        co_chair: %{
          jimbo_slooze: {Date.new!(2023, 1, 1), nil}
        },
        secretary: %{
          sassy_mcsnazzle: {Date.new!(2023, 1, 1), nil}
        },
        treasurer: %{
          fizzle_poppleton: {Date.new!(2023, 1, 1), nil}
        },
        admin: %{
          misty_fuddlewump: {Date.new!(2023, 1, 1), nil}
        }
      }
    }
  }
})

# Create some users
# Enum.each(1..3, fn n ->
#   {:ok, user} =
#     Accounts.register_user(%{
#       name: "Owner #{n}",
#       phone: "555-555-5555",
#       email: "owner@org#{n}",
#       password: "password!!!!!"
#     })

#   {:ok, organization} =
#     Organizations.create_organization(
#       %{
#         "name" => "Organization #{n}"
#       },
#       user
#     )

#   Enum.each(["Chair", "Secretary", "Treasurer", "Fluffer"], fn position_name ->
#     {:ok, position} = Positions.create_position(organization, %{"name" => position_name})

#     {:ok, user} =
#       Accounts.register_user(%{
#         name: "Organization #{n} #{position_name}",
#         phone: "555-555-5555",
#         email: "#{String.downcase(position_name)}@org#{n}",
#         password: "password!!!!!"
#       })

#     member_attrs = %{
#       "email" => user.email,
#       "active_range" => %Postgrex.Range{
#         lower: Date.new!(2024, 1, 1),
#         upper: nil,
#         lower_inclusive: true,
#         upper_inclusive: true
#       }
#     }

#     {:ok, member} = Memberships.add_membership(organization, member_attrs)

#     {:ok, tenure} =
#       Tenures.create_tenure(member, position, %{
#         "active_range" => {Date.new!(2024, 1, 1), nil}
#       })
#   end)
# end)
