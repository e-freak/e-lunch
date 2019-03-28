defmodule LunchOrder.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false
  alias LunchOrder.Repo

  alias LunchOrder.Orders.Order
  alias LunchOrder.Menus

  @doc """
  Returns the list of orders.

  ## Examples

      iex> list_orders()
      [%Order{}, ...]

  """
  def list_orders do

    Repo.all(Order)
  end

  # 個人注文一覧(月)
  def list_orders(attrs) do

    user = attrs["user"]
    month_start = Date.from_iso8601!(attrs["month"] <> "-01")
    days = Date.days_in_month(month_start)
    month_end = Date.from_iso8601!(attrs["month"] <> "-" <> Integer.to_string(days))

    #whereの中で変数を使うには変数名の前に^が必要！
    Repo.all(
      from order in Order,
        where: order.user_id == ^user and order.date >= ^month_start and order.date <= ^month_end,
      select: order
    )
  end

  def list_all_orders(date) do
    date = Date.from_iso8601!(date)

    Repo.all(
      from order in Order,
        where: order.date == ^date,
        select: order
    )
  end

  @doc """
  Gets a single order.

  Raises `Ecto.NoResultsError` if the Order does not exist.

  ## Examples

      iex> get_order!(123)
      %Order{}

      iex> get_order!(456)
      ** (Ecto.NoResultsError)

  """
  def get_order!(id), do: Repo.get!(Order, id)



  @doc """
  Creates a order.

  ## Examples

      iex> create_order(%{field: value})
      {:ok, %Order{}}

      iex> create_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order(attrs \\ %{}) do

    [year, month] = String.split(attrs["month"], "-")
    holidays = LunchOrder.Holidays.get_holiday(String.to_integer(year), String.to_integer(month))


    for order <- attrs["orders"] do
      # YYYY-MM-DD形式
      day = Integer.to_string(Enum.at(order, 0))
      date = attrs["month"] <> "-" <> String.pad_leading(day, 2, "0") #ゼロ埋め

      type = Enum.at(order, 1)
      count = Enum.at(order, 2)
      param = %{date: date, floor: attrs["floor"], lunch_count: count, lunch_type: type, user_id: attrs["user"]}

      # 過去の注文&土日祝日 編集不可
      if is_valid_date_time(date, holidays) do
        update_repp(param)
      end
    end
  end

  defp is_valid_date_time(date, holidays) do
    now = Timex.now("Asia/Tokyo")
    today = DateTime.to_date now
    time = DateTime.to_time now
    order_date = Date.from_iso8601!(date)
    days = if holidays, do: holidays.days, else: []

    # 休日かどうか
    is_holiday = Enum.any?(days, fn day -> day == order_date.day end) || Date.day_of_week(order_date) > 5
    # 締め処理後の注文が含まれていないかどうか
    time_limit = Application.get_env(:lunch_order, :order_time_limit)
    is_future = Date.compare(order_date, today) == :gt || (order_date == today && Time.compare(time, time_limit) == :lt)

    is_future && !is_holiday
  end

  defp update_repp(param) do
    order = case get_order(param) do
      nil -> %Order{}
      old_order -> old_order
    end

    # 注文データがなければDB挿入、あればDB更新
    if param.lunch_type == 0 || param.lunch_count == 0 do
      if order.id != nil do
        Repo.get!(Order, order.id)
        |> Repo.delete
      end
    else
      Order.changeset(order, param)
      |> Repo.insert_or_update
    end
  end


  defp get_order(%{user_id: user_id, date: date}) do
    Repo.one(
      from order in Order,
        where: order.date == ^date,
        where: order.user_id == ^user_id,
        select: order
    )
  end

  @doc """
  Updates a order.

  ## Examples

      iex> update_order(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Order.

  ## Examples

      iex> delete_order(order)
      {:ok, %Order{}}

      iex> delete_order(order)
      {:error, %Ecto.Changeset{}}

  """

  # 任意の日の注文を全て削除
  def delete_orders(date) do
    date
    |> LunchOrder.Orders.list_all_orders
    |> Enum.each(fn order ->
      LunchOrder.Orders.delete_order order
    end)
  end

  # 指定ユーザーの注文を全て削除
  def delete_orders_by_user(user_id) do
    Repo.all(
      from order in Order,
        where: order.user_id == ^user_id,
        select: order
    )
    |> Enum.each(fn order -> Repo.delete(order) end)
  end

  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order changes.

  ## Examples

      iex> change_order(order)
      %Ecto.Changeset{source: %Order{}}

  """
  def change_order(%Order{} = order) do
    Order.changeset(order, %{})
  end

  def outline_order(%{month: month, users: users}) do

    for user <- users do
      orders = list_orders(%{"month" => month, "user" => Integer.to_string(user.id)})
      sum = Enum.reduce(orders, 0, fn x, acc -> Menus.get_price!(x.lunch_type) * x.lunch_count + acc end)
      %{organization: user.organization, id: user.user_id, name: user.name, sum: sum}
    end

  end

  def detail_order(%{year_month: year_month, users: users}) do

    days_in_month = Date.from_iso8601!(year_month <> "-01") |> Date.days_in_month
    for user <- users do
      orders = list_orders(%{"month" => year_month, "user" => Integer.to_string(user.id)})
      amount = Enum.reduce(orders, 0, fn x, acc -> Menus.get_price!(x.lunch_type) * x.lunch_count + acc end)
      orders = Enum.map(1..days_in_month, fn day ->
        if order = Enum.find(orders, fn order -> order.date.day == day end), do: order.lunch_type, else: 0
      end)

      %{organization: user.organization, id: user.user_id, floor: user.floor, name: user.name, amount: amount, orders: orders}
    end
  end





  # def get_today_order do
  #   date = Ecto.Date.utc

  #   query = from(
  #     order in Order,
  #     where: order
  #   )

  #   Repo.get_by(Order, date: date)
  # end
end
