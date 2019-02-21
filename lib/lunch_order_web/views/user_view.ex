defmodule LunchOrderWeb.UserView do
  use LunchOrderWeb, :view
  alias LunchOrderWeb.UserView

  def render("index.json", %{users: users}) do
    render_many(users, UserView, "user.json")
  end

  def render("show.json", %{user: user}) do
    render_one(user, UserView, "user.json")
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      user_id: user.user_id,
      name: user.name,
      floor: user.floor,
      email: user.email,
      organization: user.organization,
      is_admin: user.is_admin}
  end
end
