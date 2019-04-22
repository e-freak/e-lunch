defmodule LunchOrderWeb.UserView do
  use LunchOrderWeb, :view
  alias LunchOrderWeb.UserView

  def render("index.json", %{users: users}) do
    # RITS, 管理者が先頭にくる様にソート
    Enum.sort(users, &(&1.organization == "RITS" && !&2.is_admin))
    |> render_many(UserView, "user.json")
  end

  def render("show.json", %{user: user}) do
    render_one(user, UserView, "user.json")
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      user_id: user.user_id,
      name: user.name,
      email: user.email,
      organization: user.organization,
      is_admin: user.is_admin}
  end

  def render("error.json", %{error: error}) do
    %{error: error}
  end
end
