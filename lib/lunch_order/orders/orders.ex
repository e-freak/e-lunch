defmodule LunchOrder.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false
  alias LunchOrder.Repo

  alias LunchOrder.Orders.Order

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
    # field :date, :date
    # field :floor, :integer
    # field :lunch_count, :integer
    # field :lunch_type, :integer
    # field :user_id, :string

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

    for order <- attrs["orders"] do
      # YYYY-MM-DD形式
      day = Integer.to_string(Enum.at(order, 0))
      date = attrs["month"] <> "-" <> String.pad_leading(day, 2, "0") #ゼロ埋め

      type = Enum.at(order, 1)
      count = Enum.at(order, 2)
      param = %{date: date, floor: attrs["floor"], lunch_count: count, lunch_type: type, user_id: attrs["user"]}

      # 注文データがなければDB挿入、あればDB更新
      case get_order(param) do
        nil -> %Order{}
        old_order -> old_order
      end
      |> update_repp(param)
    end
  end

  defp update_repp(order, param) do

    if param.lunch_type == 0 || param.lunch_count == 0 do
      Repo.get!(Order, order.id)
      |> Repo.delete
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


  @lunch_name ["○", "大", "小", "お", "ご", "客", "牛", "カ"]
  @lunch_price [300, 320, 280, 250, 150, 864, 350, 350]

  def outline_order(%{month: month, users: users}) do

    for user <- users do
      orders = list_orders(%{"month" => month, "user" => Integer.to_string(user.id)})
      sum = Enum.reduce(orders, 0, fn x, acc -> Enum.at(@lunch_price, x.lunch_type) + acc end)
      %{organization: user.organization, id: user.user_id, name: user.name, sum: sum}
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
