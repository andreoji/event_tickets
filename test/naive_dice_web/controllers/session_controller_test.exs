defmodule NaiveDiceWeb.SessionControllerTest do
  use NaiveDiceWeb.ConnCase

  @login_attrs %{username: "johnl", password: "j123l"}
  @invalid_attrs %{username: "ianc", password: "i123c"}

  setup do
    user = insert_user()
    _event = insert_event()
    {:ok, conn: build_conn(), user: user}
  end

  describe "Log in user" do
    test "redirects to reservation when login successful", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), session: @login_attrs)
      assert redirected_to(conn) == Routes.reservation_path(conn, :new)

      conn = get(conn, Routes.reservation_path(conn, :new))
      assert html_response(conn, 200) =~ "DON'T MISS YOUR TICKETS"
    end

    test "renders error message when login failed", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), session: @invalid_attrs)
      assert html_response(conn, 200) =~ "Invalid username/password combination"
    end
  end

  describe "Log out user" do
    test "redirects to login page when logout successful", %{conn: conn, user: user} do
      conn = post(conn, Routes.session_path(conn, :create), session: @login_attrs)
      assert redirected_to(conn) == Routes.reservation_path(conn, :new)

      conn = delete(conn, Routes.session_path(conn, :delete, user.id))
      assert conn.status == 302
      assert redirected_to(conn) == "/"
    end
  end
end