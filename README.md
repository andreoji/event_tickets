# NaiveDice

  * There are eight users in the system.
  * There is one event titled, "The Sound of Music".

To run the tests:

  * Run `mix test`


## The schema consists of 4 tables

  * __Events__ - an event has an `event_status` of `active`, `sold_out` or `archived`. Additionally its `title` is 					unique.
  * __Reservations__ - a `user`, will only ever have one reservation for an `event`. A reservation has a `status` of				`active`, `expired` or `completed`.
  * __Payments__ - a `user` will only ever make one payment for an event. `stripity-stripe`'s charge object creation is 		idempotent by default. The charge object `id` is captured as a payment's `stripe_payment_id` and is unique.
  * __Users__ - `username`, `name` and `email` are all unique.

## Edge cases

  * __Active reservations__ - on restart, the `supervision` mechanism is used to check for any reservations that may 				have been left in the `active` state; due to the appliction crashing / being stopped and then restarted. Any 					`active` reservations then have an expiry task set, as their original expiry task would have been lost.
  * __Network problems__ - a `post` to the `/charge` endpoint is idempotent by default, there is no need to explicity 			set an `idempotency-key` in the headers.
  * __Misbehaving users__ - there are checks against the `current_user` for `full name` and `email` entered.
  * __Stripe outage__ - the payment steps are transactional - as with all other steps in the transaction - the step of			calling the Stripe API must be successful, otherwise the transaction will be rolled back.
