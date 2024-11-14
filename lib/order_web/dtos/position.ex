defmodule OrderWeb.DTO.Position do
  alias __MODULE__
  alias OrderWeb.DTO.PositionTenure
  import Order.DateHelper

  defstruct id: nil,
            organization_id: nil,
            name: "",
            description: "",
            requires_report: false,
            current_tenures: [],
            past_tenures: []

  @type t :: %Position{
          id: integer(),
          organization_id: integer(),
          name: String.t(),
          description: String.t(),
          requires_report: boolean(),
          current_tenures: [PositionTenure.t()],
          past_tenures: [PositionTenure.t()]
        }

  def map(%Order.Organizations.Position{} = p) do
    tenures = Enum.map(p.tenures, &PositionTenure.map_tenure/1)

    %Position{
      id: p.id,
      organization_id: p.organization_id,
      name: p.name,
      description: p.description,
      requires_report: p.requires_report,
      current_tenures:
        tenures
        |> Enum.filter(&in_range?(&1.active_range, Date.utc_today())),
      past_tenures: tenures |> Enum.reject(&in_range?(&1.active_range, Date.utc_today()))
    }
  end

  def map_list([%Order.Organizations.Position{} | _] = positions) do
    Enum.map(positions, &map/1)
  end

  def map_list([]), do: []

  def unmap(%Position{} = p) do
    %Order.Organizations.Position{
      id: p.id,
      organization_id: p.organization_id,
      name: p.name,
      description: p.description,
      requires_report: p.requires_report
    }
  end
end

defmodule OrderWeb.DTO.PositionTenure do
  alias __MODULE__
  alias Order.Organizations.Tenure

  defstruct id: nil,
            membership_id: nil,
            user_id: nil,
            active_range: %Postgrex.Range{},
            name: "",
            email: "",
            phone: ""

  @type t :: %PositionTenure{
          id: nil,
          membership_id: integer(),
          user_id: integer(),
          active_range: Postgrex.Range.t(),
          name: String.t(),
          email: String.t(),
          phone: String.t()
        }
  def map_tenure(%Tenure{} = t) do
    %PositionTenure{
      id: t.id,
      membership_id: t.membership_id,
      user_id: t.user.id,
      active_range: t.active_range,
      name: t.user.name,
      email: t.user.email,
      phone: t.user.phone
    }
  end
end
