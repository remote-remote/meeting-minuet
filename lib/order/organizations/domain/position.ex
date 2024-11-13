defmodule Order.Organizations.Position do
  import Ecto.{Changeset, Query}
  import Order.DateHelper
  use Ecto.Schema
  use Order.DomainModel, db_module: Order.DB.Position
  alias Order.{DB}

  embedded_schema do
    field :name, :string
    field :description, :string
    field :requires_report, :boolean, default: false

    embeds_many :current_tenures, Order.Organizations.Tenure
    embeds_many :past_tenures, Order.Organizations.Tenure
  end

  def changeset(%Order.Organizations.Position{} = position, attrs) do
    position
    |> cast(attrs, [:name, :description, :requires_report])
    |> validate_required([:name])
    |> cast_embed(:current_tenures)
  end

  def from_db(%DB.Position{} = p) do
    tenures = Enum.map(p.tenures, &Order.Organizations.Tenure.from_db/1)

    %{
      id: p.id,
      name: p.name,
      description: p.description,
      requires_report: p.requires_report,
      current_tenures:
        tenures
        |> Enum.filter(&in_range?(&1.active_range, Date.utc_today())),
      past_tenures: tenures |> Enum.reject(&in_range?(&1.active_range, Date.utc_today()))
    }
  end

  def to_db(%Order.Organizations.Position{} = p) do
    %DB.Position{
      id: p.id,
      name: p.name,
      description: p.description,
      requires_report: p.requires_report,
      tenures: Enum.map(p.current_tenures ++ p.past_tenures, &Order.Organizations.Tenure.to_db/1)
    }
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

  def from_db(%Order.DB.Tenure{} = t) do
    %{
      name: t.user.name,
      email: t.user.email,
      phone: t.user.phone,
      active_range: t.active_range
    }
  end

  def to_db(%Order.Organizations.Tenure{} = t) do
    %Order.DB.Tenure{
      user: %Order.Accounts.User{},
      active_range: t.active_range
    }
  end
end
