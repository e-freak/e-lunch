defmodule LunchOrder.HolidaysTest do
  use LunchOrder.DataCase

  alias LunchOrder.Holidays

  describe "holidays" do
    alias LunchOrder.Holidays.Holiday

    @valid_attrs %{date: ~D[2010-04-17]}
    @update_attrs %{date: ~D[2011-05-18]}
    @invalid_attrs %{date: nil}

    def holiday_fixture(attrs \\ %{}) do
      {:ok, holiday} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Holidays.create_holiday()

      holiday
    end

    test "list_holidays/0 returns all holidays" do
      holiday = holiday_fixture()
      assert Holidays.list_holidays() == [holiday]
    end

    test "get_holiday!/1 returns the holiday with given id" do
      holiday = holiday_fixture()
      assert Holidays.get_holiday!(holiday.id) == holiday
    end

    test "create_holiday/1 with valid data creates a holiday" do
      assert {:ok, %Holiday{} = holiday} = Holidays.create_holiday(@valid_attrs)
      assert holiday.date == ~D[2010-04-17]
    end

    test "create_holiday/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Holidays.create_holiday(@invalid_attrs)
    end

    test "update_holiday/2 with valid data updates the holiday" do
      holiday = holiday_fixture()
      assert {:ok, holiday} = Holidays.update_holiday(holiday, @update_attrs)
      assert %Holiday{} = holiday
      assert holiday.date == ~D[2011-05-18]
    end

    test "update_holiday/2 with invalid data returns error changeset" do
      holiday = holiday_fixture()
      assert {:error, %Ecto.Changeset{}} = Holidays.update_holiday(holiday, @invalid_attrs)
      assert holiday == Holidays.get_holiday!(holiday.id)
    end

    test "delete_holiday/1 deletes the holiday" do
      holiday = holiday_fixture()
      assert {:ok, %Holiday{}} = Holidays.delete_holiday(holiday)
      assert_raise Ecto.NoResultsError, fn -> Holidays.get_holiday!(holiday.id) end
    end

    test "change_holiday/1 returns a holiday changeset" do
      holiday = holiday_fixture()
      assert %Ecto.Changeset{} = Holidays.change_holiday(holiday)
    end
  end
end
