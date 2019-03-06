defmodule LunchOrder.Holidays do
  @moduledoc """
  The Holidays context.
  """

  import Ecto.Query, warn: false
  alias LunchOrder.Repo

  alias LunchOrder.Holidays.Holiday

  @doc """
  Returns the list of holidays.

  ## Examples

      iex> list_holidays()
      [%Holiday{}, ...]

  """
  def list_holidays do
    Repo.all(Holiday)
  end

  @doc """
  Gets a single holiday.

  Raises `Ecto.NoResultsError` if the Holiday does not exist.

  ## Examples

      iex> get_holiday!(123)
      %Holiday{}

      iex> get_holiday!(456)
      ** (Ecto.NoResultsError)

  """
  def get_holiday!(id), do: Repo.get!(Holiday, id)


  def get_holiday(year, month) do
    Repo.one(
      from holiday in Holiday,
        where: holiday.year == ^year,
        where: holiday.month == ^month,
        select: holiday
    )
  end

  @doc """
  Updates a holiday.

  ## Examples

      iex> update_holiday(holiday, %{field: new_value})
      {:ok, %Holiday{}}

      iex> update_holiday(holiday, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_holiday(year, month, days) do

    case get_holiday(year, month) do
      nil -> %Holiday{}
      holiday -> holiday
    end
    |> Holiday.changeset(%{year: year, month: month, days: days})
    |> Repo.insert_or_update()
  end

  @doc """
  Deletes a Holiday.

  ## Examples

      iex> delete_holiday(holiday)
      {:ok, %Holiday{}}

      iex> delete_holiday(holiday)
      {:error, %Ecto.Changeset{}}

  """
  def delete_holiday(%Holiday{} = holiday) do
    Repo.delete(holiday)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking holiday changes.

  ## Examples

      iex> change_holiday(holiday)
      %Ecto.Changeset{source: %Holiday{}}

  """
  def change_holiday(%Holiday{} = holiday) do
    Holiday.changeset(holiday, %{})
  end

end
