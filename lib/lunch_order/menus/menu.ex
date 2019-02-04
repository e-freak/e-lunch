defmodule LunchOrder.Menus.Menu do
  use Ecto.Schema
  import Ecto.Changeset


  schema "menus" do
    field :name, :string
    field :price, :integer
    field :symbol, :string

    timestamps()
  end

  @doc false
  def changeset(menu, attrs) do
    menu
    |> cast(attrs, [:name, :symbol, :price])
    |> validate_required([:name, :symbol, :price])
  end
end
