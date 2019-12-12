defmodule NaiveDiceWeb.UserController do
  use NaiveDiceWeb, :controller

  alias NaiveDice.Accounts
  alias NaiveDice.Accounts.User
  alias NaiveDiceWeb.Endpoint

  def index(conn, _params) do
    conn
    |> assign(:current_user, Guardian.Plug.current_resource(conn))
    |> render("index.html")
  end

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> NaiveDice.Auth.login(user)
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.user_path(Endpoint, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user(id)
    render(conn, "show.html", user: user)
  end
end