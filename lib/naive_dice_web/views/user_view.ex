defmodule NaiveDiceWeb.UserView do
  use NaiveDiceWeb, :view

  def render("user.json", %{user: user}) do
    %{id: user.id, username: user.name}
  end
end