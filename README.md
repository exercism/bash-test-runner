# bash-test-runner

Exercism.io test runner for Bash.

First runs the tests with bats and saves the TAP output, then parses that TAP
file to produce the JSON file.

The aim is just to parse the output of [bats](https://github.com/bats-core/bats-core), not to be a full [TAP](https://testanything.org) parser.

The state `error` is only used if the entire test run fails.

If the tests can run, only the states `fail` and `pass` are used, as `bats` (or
at least TAP) does not distinguish between failures and errors.

