defmodule LunchOrder.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :user_id, :string
      add :date, :date
      add :floor, :integer
      add :lunch_type, :integer
      add :lunch_count, :integer

      timestamps()
    end

  end
end
