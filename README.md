# README

## Setup instructions

```sh
bundle
rake db:setup
rails dev:cache
```

## How to test

To run the automatic tests:

```sh
rspec
```

Visit the login endpoint (http://localhost:3000/users/sign_in) for logging in with following credentials:

```
email: 'user@example.com'
password: 'book-me-now'
```

To see the seed data on the browser, you can visit the following endpoints:

* http://localhost:3000/events?limit=10&offset=0

* http://localhost:3000/bookings/list_mine?limit=10&offset=0

`limit` takes any values from 1 too 100.

## Further improvements

Here are some potential enhancements:

* add tests for the Interactor themselves.

* add test to ensure that passing a `user_id` param in the request to the `Events#authored` and `Bookings::ListMine` actions doesn't show results for users other than `current_user`.

* add test to ensure that passing a `user_id` param in the request to the `Events#create` and `Bookings::Create` actions doesn't create events or bookings for users other than `current_user`.

* alternatively, make `current_user` available on the interactors mentioned above and remove the `user_id` parameter from such interactors.

* add a `nested` boolean parameter to the 'GET /bookings/list_mine' endpoint so that it nests the bookings under the `bookings` key and provides the events data under the `events` key.

* provide a better UI for logging in and out.
  - for the root path, add a redirection to `/users/sign_in` when the user is not logged in.

* the interactors are tested indirectly through controller tests, there should be coverage for the interactors as well.
