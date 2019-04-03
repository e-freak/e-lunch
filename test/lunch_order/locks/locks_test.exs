defmodule LunchOrder.LocksTest do
  use LunchOrder.DataCase

  alias LunchOrder.Locks

  describe "locks" do
    alias LunchOrder.Locks.Lock

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def lock_fixture(attrs \\ %{}) do
      {:ok, lock} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Locks.create_lock()

      lock
    end

    test "list_locks/0 returns all locks" do
      lock = lock_fixture()
      assert Locks.list_locks() == [lock]
    end

    test "get_lock!/1 returns the lock with given id" do
      lock = lock_fixture()
      assert Locks.get_lock!(lock.id) == lock
    end

    test "create_lock/1 with valid data creates a lock" do
      assert {:ok, %Lock{} = lock} = Locks.create_lock(@valid_attrs)
    end

    test "create_lock/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Locks.create_lock(@invalid_attrs)
    end

    test "update_lock/2 with valid data updates the lock" do
      lock = lock_fixture()
      assert {:ok, lock} = Locks.update_lock(lock, @update_attrs)
      assert %Lock{} = lock
    end

    test "update_lock/2 with invalid data returns error changeset" do
      lock = lock_fixture()
      assert {:error, %Ecto.Changeset{}} = Locks.update_lock(lock, @invalid_attrs)
      assert lock == Locks.get_lock!(lock.id)
    end

    test "delete_lock/1 deletes the lock" do
      lock = lock_fixture()
      assert {:ok, %Lock{}} = Locks.delete_lock(lock)
      assert_raise Ecto.NoResultsError, fn -> Locks.get_lock!(lock.id) end
    end

    test "change_lock/1 returns a lock changeset" do
      lock = lock_fixture()
      assert %Ecto.Changeset{} = Locks.change_lock(lock)
    end
  end
end
