defmodule LunchOrder.Repo.Migrations.CreateHolidays do
  use Ecto.Migration

  def change do
    create table(:holidays) do
      add :year, :integer
      add :month, :integer
      add :days, {:array, :integer}

      timestamps()
    end

  end
end
