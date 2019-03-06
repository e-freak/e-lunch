defmodule LunchOrder.Menus do
  @moduledoc """
  The Menus context.
  """

  import Ecto.Query, warn: false
  alias LunchOrder.Repo

  alias LunchOrder.Menus.Menu

  @lunch_mark ["○", "大", "小", "お", "ご", "客", "牛", "カ"]
  @lunch_name ["普通弁当", "普通弁当 ご飯大盛", "普通弁当 ご飯小盛", "おかずのみ", "ご飯のみ", "お客様様弁当", "牛丼", "カレーライス"]
  @lunch_price [300, 320, 280, 250, 150, 864, 350, 350]

  @doc """
  Returns the list of menus.

  ## Examples

      iex> list_menus()
      [%Menu{}, ...]

  """
  def list_menus do
    Repo.all(Menu)
  end

  @doc """
  Gets a single menu.

  Raises `Ecto.NoResultsError` if the Menu does not exist.

  ## Examples

      iex> get_menu!(123)
      %Menu{}

      iex> get_menu!(456)
      ** (Ecto.NoResultsError)

  """
  def get_menu!(id), do: Repo.get!(Menu, id)

  @doc """
  Creates a menu.

  ## Examples

      iex> create_menu(%{field: value})
      {:ok, %Menu{}}

      iex> create_menu(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_menu(attrs \\ %{}) do
    %Menu{}
    |> Menu.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a menu.

  ## Examples

      iex> update_menu(menu, %{field: new_value})
      {:ok, %Menu{}}

      iex> update_menu(menu, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_menu(%Menu{} = menu, attrs) do
    menu
    |> Menu.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Menu.

  ## Examples

      iex> delete_menu(menu)
      {:ok, %Menu{}}

      iex> delete_menu(menu)
      {:error, %Ecto.Changeset{}}

  """
  def delete_menu(%Menu{} = menu) do
    Repo.delete(menu)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking menu changes.

  ## Examples

      iex> change_menu(menu)
      %Ecto.Changeset{source: %Menu{}}

  """
  def change_menu(%Menu{} = menu) do
    Menu.changeset(menu, %{})
  end
end
