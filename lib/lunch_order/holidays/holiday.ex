defmodule LunchOrder.Holidays.Holiday do
  use Ecto.Schema
  import Ecto.Changeset


  schema "holidays" do
    field :year, :integer
    field :month, :integer
    field :days, {:array, :integer}

    timestamps()
  end

  @doc false
  def changeset(holiday, attrs) do
    holiday
    |> cast(attrs, [:year, :month, :days])
    |> validate_required([:year, :month, :days])
  end
end
