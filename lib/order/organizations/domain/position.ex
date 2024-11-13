defmodule Order.Organizations.Position do
  use Ecto.Schema

  embedded_schema do
    field :name, :string
    field :description, :string
    field :requires_report, :boolean

    embeds_many :tenures, Order.Organizations.Tenure
  end
end

defmodule Order.Organizations.Tenure do
  use Ecto.Schema

  embedded_schema do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :active_range, EctoRange.Date
  end
end
