defmodule NaiveDiceWeb.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: NaiveDice.Repo
  alias NaiveDice.Accounts.User
  alias NaiveDice.Tickets.{Event, Payment, Reservation}
  @event_title Application.get_env(:naive_dice, :event_title)

  def event_factory do
    %Event{
      title: @event_title,
      price: 1999,
      currency: "USD",
      capacity: 5,
      event_status: :active,
      number_sold: 0 
    }
  end

  def user_factory do
    password = sequence(:password, &"j123d#{&1}")
    %User{
      name: sequence(:name, &"john doe#{&1}"),
      username: sequence(:username, &"johnd#{&1}"),
      email: sequence(:email, &"john#{&1}@acme.com"),
      password: password,
      password_hash: password |> Bcrypt.hash_pwd_salt
    }
  end

  def reservation_factory do
    %Reservation{
      status: :active,
      event_id: build(:event),
      user_id: build(:user)
    }
  end

  def payment_factory do
    %Payment{
      stripe_payment_id: sequence(:stripe_payment_id, &"ch_#{&1}FqHamHCCcwyjBBXsipQMPMT"),
      event_id: build(:event),
      user_id: build(:user)
    }
  end
end