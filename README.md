# Exercism Bash Test Runner

The Docker image to automatically run tests on Bash solutions submitted to [Exercism].

## Run the test runner

To run the tests of an arbitrary exercise, do the following:

1. Open a terminal in the project's root
2. Run `./bin/run.sh <exercise-slug> <solution-dir> <output-dir>`

Once the test runner has finished, its results will be written to `<output-dir>/results.json`.

## Run the test runner on an exercise using Docker

_This script is provided for testing purposes, as it mimics how test runners run in Exercism's production environment._

To run the tests of an arbitrary exercise using the Docker image, do the following:

1. Open a terminal in the project's root
2. Run `./bin/run-in-docker.sh <exercise-slug> <solution-dir> <output-dir>`

Once the test runner has finished, its results will be written to `<output-dir>/results.json`.

## Run the tests

To run the tests to verify the behavior of the test runner, do the following:

1. Open a terminal in the project's root
2. Run `./bin/run-tests.sh`

These are [golden tests][golden] that compare the `results.json` generated by running the current state of the code against the "known good" `tests/<test-name>/results.json`. All files created during the test run itself are discarded.

When you've made modifications to the code that will result in a new "golden" state, you'll need to generate and commit a new `tests/<test-name>/results.json` file.

## Run the tests using Docker

_This script is provided for testing purposes, as it mimics how test runners run in Exercism's production environment._

To run the tests to verify the behavior of the test runner using the Docker image, do the following:

1. Open a terminal in the project's root
2. Run `./bin/run-tests-in-docker.sh`

These are [golden tests][golden] that compare the `results.json` generated by running the current state of the code against the "known good" `tests/<test-name>/results.json`. All files created during the test run itself are discarded.

When you've made modifications to the code that will result in a new "golden" state, you'll need to generate and commit a new `tests/<test-name>/results.json` file.

[test-runners]: https://github.com/exercism/automated-tests/blob/master/docs/introduction.md
[golden]: https://ro-che.info/articles/2017-12-04-golden-tests
[exercism]: https://exercism.io
