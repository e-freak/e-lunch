defmodule LunchOrder.Locks.Lock do
  use Ecto.Schema
  import Ecto.Changeset


  schema "locks" do
    field :email, :string
    field :fail_time_list, {:array, :utc_datetime}

    timestamps()
  end

  @doc false
  def changeset(lock, attrs) do
    lock
    |> cast(attrs, [:email, :fail_time_list])
    |> validate_required([:email, :fail_time_list])
  end
end
