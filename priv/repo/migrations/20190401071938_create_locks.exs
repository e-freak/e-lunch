defmodule LunchOrder.Repo.Migrations.CreateLocks do
  use Ecto.Migration

  def change do
    create table(:locks) do
      add :email, :string
      add :fail_time_list, {:array, :utc_datetime}

      timestamps()
    end

  end
end
