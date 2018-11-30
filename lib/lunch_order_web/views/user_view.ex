defmodule LunchOrderWeb.UserView do
  use LunchOrderWeb, :view
  alias LunchOrderWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      user_id: user.user_id,
      name: user.name,
      password_hash: user.password_hash,
      email: user.email,
      organization: user.organization,
      is_admin: user.is_admin}
  end
end
