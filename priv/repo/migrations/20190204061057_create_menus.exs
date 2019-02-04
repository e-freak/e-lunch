defmodule LunchOrder.Repo.Migrations.CreateMenus do
  use Ecto.Migration

  def change do
    create table(:menus) do
      add :name, :string
      add :symbol, :string
      add :price, :integer

      timestamps()
    end

  end
end
