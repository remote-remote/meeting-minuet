defmodule MeetingMinuetWeb.DTO.Member do
  alias __MODULE__
  import MeetingMinuet.DateHelper
  alias MeetingMinuet.Organizations.Membership
  alias MeetingMinuetWeb.DTO.MemberPosition

  defstruct id: nil,
            user_id: nil,
            name: "",
            email: "",
            phone: "",
            roles: [],
            active_range: %Postgrex.Range{},
            current_positions: [],
            past_positions: []

  @type t :: %Member{
          id: integer(),
          user_id: integer(),
          name: String.t(),
          email: String.t(),
          phone: String.t(),
          roles: [atom()],
          active_range: Postgrex.Range.t(),
          past_positions: [MemberPosition.t()],
          current_positions: [MemberPosition.t()]
        }

  def map_list([%Membership{} | _] = list) do
    Enum.map(list, &map_preloaded_membership/1)
  end

  def map_preloaded_membership(
        %Membership{user: %MeetingMinuet.Accounts.User{}, tenures: tenures} = m,
        date \\ Date.utc_today()
      )
      when is_list(tenures) do
    %MeetingMinuetWeb.DTO.Member{
      id: m.id,
      user_id: m.user_id,
      name: m.user.name,
      email: m.user.email,
      phone: m.user.phone,
      active_range: m.active_range,
      roles: m.roles,
      current_positions:
        m.tenures
        |> Enum.filter(fn t ->
          in_range?(t.active_range, date)
        end)
        |> Enum.map(&MeetingMinuetWeb.DTO.MemberPosition.map_preloaded_tenure(&1)),
      past_positions:
        m.tenures
        |> Enum.reject(fn t ->
          in_range?(t.active_range, date)
        end)
        |> Enum.map(&MeetingMinuetWeb.DTO.MemberPosition.map_preloaded_tenure(&1))
    }
  end
end

defmodule MeetingMinuetWeb.DTO.MemberPosition do
  alias __MODULE__
  alias MeetingMinuet.Organizations.{Position, Tenure}

  defstruct name: "",
            description: "",
            active_range: %Postgrex.Range{},
            position_id: nil,
            tenure_id: nil

  @type t :: %MemberPosition{
          name: String.t(),
          description: String.t(),
          active_range: Postgrex.Range.t(),
          position_id: integer(),
          tenure_id: integer()
        }

  def map_preloaded_tenure(%Tenure{position: %Position{}} = t) do
    %MemberPosition{
      position_id: t.position_id,
      tenure_id: t.id,
      name: t.position.name,
      description: t.position.description,
      active_range: t.active_range
    }
  end
end
