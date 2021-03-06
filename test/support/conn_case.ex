defmodule NaiveDiceWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use NaiveDiceWeb.ConnCase, async: true`, although
  this option is not recommendded for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      alias NaiveDiceWeb.Router.Helpers, as: Routes
      import NaiveDiceWeb.TestHelpers.{Factory, NamedSetup}

      # The default endpoint for testing
      @endpoint NaiveDiceWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(NaiveDice.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(NaiveDice.Repo, {:shared, self()})
    end
    use Phoenix.ConnTest

    alias NaiveDiceWeb.Router.Helpers, as: Routes
    
    conn = build_conn()

    post_session_fun = fn user, conn ->
      Phoenix.ConnTest.dispatch(conn,
        NaiveDiceWeb.Endpoint,
        :post, Routes.session_path(conn, :create),
        session: %{username: user.username, password: user.password}
      )
    end
   
    {:ok, conn: conn, post_session_fun: post_session_fun}
  end
end
