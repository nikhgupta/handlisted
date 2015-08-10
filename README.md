CuratedShop
===========

This is a short description of your app. You MUST replace it, before
you even think about pushing this application to Github.

## TODO

- TODO: Update the README.

Test Suite
==========

Test suite can be run along with following environment variables:

- **DEBUG=1**: Open HTML page (and screenshot for JS tests) when tests fail
- **DEBUG=js**: Run Poltergeist based debugger and `DEBUG=1`
- **WITH_JS=1**: Run tests using Poltergeist driver
- **WITH_LINT=1**: Lint all FactoryGirl factories before running tests
- **COVERAGE=1**: Run `WITH_JS=1` and `WITH_LINT=1`
- **SLEEP=1**: Count user specified sleeping time spent in tests (only counted when time is >= 0.1 seconds)
- **SLEEP=capybara**: Count sleeping time spent by Capybara while waiting for finders
- **SLEEP=traffic**: Count sleeping time spent by Poltergeist while waiting for network traffic to end
- **SLEEP=all**: Run `SLEEP=1`, `SLEEP=capybara`, `SLEEP=traffic` together.

Note: in all `SLEEP` counters, overall time spent in `sleep` method is always reported.
