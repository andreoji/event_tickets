defmodule NaiveDiceWeb.PaymentView do
  use NaiveDiceWeb, :view

  def csrf_token, do: Phoenix.Controller.get_csrf_token()
  def stripe_pub_key, do: Application.get_env(:naive_dice, :stripe_pub_key)
end