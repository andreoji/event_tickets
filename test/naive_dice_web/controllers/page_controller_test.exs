defmodule NaiveDiceWeb.PageControllerTest do
  use NaiveDiceWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Naive Dice!"
  end
end
