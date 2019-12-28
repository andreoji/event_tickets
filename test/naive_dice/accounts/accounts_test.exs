defmodule NaiveDice.Accounts.Test do
  use NaiveDice.DataCase
  import Ecto.Query, warn: false
  alias NaiveDice.Accounts

  describe "check_name/2" do
    setup [:create_event, :create_user]

    test "returns the correct user when name is correct", %{
      user: user
    } do
      
      {:ok, u} = user |> Accounts.check_name(user.name)

      assert u.name == user.name
      assert u.username == user.username
      assert u.email == user.email
    end

    test "returns an error when name is incorrect", %{
      user: user
    } do
      
      assert {:error, "The full name entered doesn't match"} = user |> Accounts.check_name("jane doe")
    end
  end

  describe "check_email/2" do
    setup [:create_event, :create_user]

    test "returns the correct user when email is correct", %{
      user: user
    } do
      
      {:ok, u} = user |> Accounts.check_email(user.email)

      assert u.name == user.name
      assert u.username == user.username
      assert u.email == user.email
    end

    test "returns an error when email is incorrect", %{
      user: user
    } do
      
      assert {:error, "The email entered doesn't match"} = user |> Accounts.check_email("jane@doe.com")
    end
  end

  describe "create_user/1" do
    setup [:create_event, :create_user]

    test "returns an error when full name is non-unique", %{
      user: user
    } do
      
      attrs = %{
        email: "jane@doe.com",
        name: user.name,
        username: "janed",
        password: "j123d",
      }
      {:error, changeset} = attrs |> Accounts.create_user
      assert %{name: ["has already been taken"]} = errors_on(changeset)
    end

    test "returns an error when username is non-unique", %{
      user: user
    } do
      
      attrs = %{
        email: "jane@doe.com",
        name: "jane doe",
        username: user.username,
        password: "j123d",
      }
      {:error, changeset} = attrs |> Accounts.create_user
      assert %{username: ["has already been taken"]} = errors_on(changeset)
    end

    test "returns an error when email is non-unique", %{
      user: user
    } do
      
      attrs = %{
        email: user.email,
        name: "jane doe",
        username: "janed",
        password: "j123d",
      }
      {:error, changeset} = attrs |> Accounts.create_user
      assert %{email: ["has already been taken"]} = errors_on(changeset)
    end

    test "returns a user when attrs are all valid" do
      attrs = %{
        email: "jane@doe.com",
        name: "jane doe",
        username: "janed",
        password: "j123d",
      }
      assert {:ok, u} = attrs |> Accounts.create_user
      assert u.name == attrs.name
      assert u.username == attrs.username
      assert u.email == attrs.email
    end
  end
end