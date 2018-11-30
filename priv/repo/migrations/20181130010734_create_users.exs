defmodule LunchOrder.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :user_id, :string
      add :name, :string
      add :password_hash, :string
      add :email, :string
      add :organization, :string
      add :is_admin, :boolean, default: false, null: false

      timestamps()
    end

  end
end
