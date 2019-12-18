# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     NaiveDice.Repo.insert!(%NaiveDice.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
NaiveDice.Repo.insert!(%NaiveDice.Tickets.Event{
    title: "The Sound of Music",
    capacity: 5,
    price: 1999,
    currency: "USD",
    event_status: :active
  })

NaiveDice.Accounts.create_user(%{
  name: "john lennon",
  username: "johnl",
  password: "j123l",
  email: "john@acme.com"
})

NaiveDice.Accounts.create_user(%{
  name: "paul mcartney",
  username: "paulm",
  password: "p123m",
  email: "paul@acme.com"
})

NaiveDice.Accounts.create_user(%{
  name: "george harrison",
  username: "georgeh",
  password: "g123h",
  email: "george@acme.com"
})

NaiveDice.Accounts.create_user(%{
  name: "ringo starr",
  username: "ringos",
  password: "r123s",
  email: "ringo@acme.com"
})

NaiveDice.Accounts.create_user(%{
  name: "mick jagger",
  username: "mickj",
  password: "m123j",
  email: "mick@acme.com"
})

NaiveDice.Accounts.create_user(%{
  name: "keith richards",
  username: "keithr",
  password: "k123r",
  email: "keith@acme.com"
})

NaiveDice.Accounts.create_user(%{
  name: "charlie watts",
  username: "charliew",
  password: "c123w",
  email: "charlie@acme.com"
})

NaiveDice.Accounts.create_user(%{
  name: "brian jones",
  username: "brianj",
  password: "b123j",
  email: "brian@acme.com"
})
