defmodule LunchOrder.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset


  schema "orders" do
    field :date, :date
    field :floor, :integer
    field :lunch_count, :integer
    field :lunch_type, :integer
    field :user_id, :string

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:user_id, :date, :floor, :lunch_type, :lunch_count])
    |> validate_required([:user_id, :date, :floor, :lunch_type, :lunch_count])
  end
end
