defmodule NaiveDice.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias NaiveDice.Repo
  alias NaiveDice.Accounts.User

  def list_users do
    User
    |> Repo.all()
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.create_changeset(attrs)
    |> Repo.insert()
  end

  def get_user(id) do
    User
    |> Repo.get(id)
  end

  def check_name(user, name) do
    (from u in User, where: u.id == ^user.id and
                                  u.name == ^name)
    |> Repo.one
    |> case do
         nil -> {:error, "The full name entered doesn't match"}
         user -> {:ok, user}
    end
  end

  def check_email(user, email) do
    (from u in User, where: u.id == ^user.id and
                                  u.email == ^email)
    |> Repo.one
    |> case do
         nil -> {:error, "The email entered doesn't match"}
         user -> {:ok, user}
    end
  end

  def change_user_registration(%User{} = user) do
    User.create_changeset(user, %{})
  end
end