defmodule LunchOrderWeb.HolidayControllerTest do
  use LunchOrderWeb.ConnCase

  alias LunchOrder.Holidays
  alias LunchOrder.Holidays.Holiday

  @create_attrs %{date: ~D[2010-04-17]}
  @update_attrs %{date: ~D[2011-05-18]}
  @invalid_attrs %{date: nil}

  def fixture(:holiday) do
    {:ok, holiday} = Holidays.create_holiday(@create_attrs)
    holiday
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all holidays", %{conn: conn} do
      conn = get conn, holiday_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create holiday" do
    test "renders holiday when data is valid", %{conn: conn} do
      conn = post conn, holiday_path(conn, :create), holiday: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, holiday_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "date" => ~D[2010-04-17]}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, holiday_path(conn, :create), holiday: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update holiday" do
    setup [:create_holiday]

    test "renders holiday when data is valid", %{conn: conn, holiday: %Holiday{id: id} = holiday} do
      conn = put conn, holiday_path(conn, :update, holiday), holiday: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, holiday_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "date" => ~D[2011-05-18]}
    end

    test "renders errors when data is invalid", %{conn: conn, holiday: holiday} do
      conn = put conn, holiday_path(conn, :update, holiday), holiday: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete holiday" do
    setup [:create_holiday]

    test "deletes chosen holiday", %{conn: conn, holiday: holiday} do
      conn = delete conn, holiday_path(conn, :delete, holiday)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, holiday_path(conn, :show, holiday)
      end
    end
  end

  defp create_holiday(_) do
    holiday = fixture(:holiday)
    {:ok, holiday: holiday}
  end
end
