defmodule NaiveDiceWeb.Router do
  use NaiveDiceWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug(NaiveDice.Auth.AuthAccessPipeline)
  end

  scope "/", NaiveDiceWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources("/users", UserController, only: [:new, :create])
    resources("/sessions", SessionController, only: [:new, :create])
  end

  scope "/", NaiveDiceWeb do
    pipe_through [:browser, :auth]

    resources "/reservations", ReservationController, only: [:new, :create]
    resources "/payments", PaymentController, only: [:new, :create]
    resources("/sessions", SessionController, only: [:delete])
  end

  # Other scopes may use custom stacks.
  # scope "/api", NaiveDiceWeb do
  #   pipe_through :api
  # end
end
