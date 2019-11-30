defmodule NaiveDice.Auth.AuthAccessPipeline do
  @moduledoc false

  use Guardian.Plug.Pipeline, otp_app: :naive_dice

  plug(Guardian.Plug.VerifySession, claims: %{"typ" => "access"})
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource)
end