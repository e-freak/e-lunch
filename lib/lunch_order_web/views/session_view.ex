defmodule LunchOrderWeb.SessionView do
  use LunchOrderWeb, :view

  def render("login.json", %{user: user, jwt: jwt}) do
    %{token: jwt, id: user.id, name: user.name}
  end

  def render("error.json", %{message: msg}) do
    %{"error": msg}
  end

  def render("logout.json", %{message: msg}) do
    %{message: msg}
  end
end
