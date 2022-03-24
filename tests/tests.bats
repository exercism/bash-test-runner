#!/usr/bin/env bats

RUN_SCRIPT='./bin/run.sh'
DATA_DIR='tests/data'

actual_matches_expected() {
    local actual=$1 expected=$2

    # Look at parts of the results instead of just comparing the file contents:
    # when we upgrade the base image of the test container and the tool
    # versions change, we won't need to go back and "fix" the expected result
    # files.

    [[ "$(jq .version "$actual")" == "$(jq .version "$expected")" ]] &&
    [[ "$(jq .status "$actual")" == "$(jq .status "$expected")" ]] &&
    [[ "$(jq .tests "$actual")" == "$(jq .tests "$expected")" ]] &&
    [[ -n "$(jq '."test-environment".bash' "$actual")" ]] &&
    [[ -n "$(jq '."test-environment".bats' "$actual")" ]]
}

@test "one passing test" {
    TEST="one_passing"
    TEST_DIR="$DATA_DIR/$TEST"
    run "$RUN_SCRIPT" "$TEST" "$TEST_DIR" "$TEST_DIR"

    [[ "$status" -eq 0 ]]
    actual_matches_expected "$TEST_DIR/results.json" "$TEST_DIR/expected_results.json"
}

@test "three passing tests" {
    TEST="three_passing"
    TEST_DIR="$DATA_DIR/$TEST"
    run "$RUN_SCRIPT" "$TEST" "$TEST_DIR" "$TEST_DIR"

    [[ "$status" -eq 0 ]]
    actual_matches_expected "$TEST_DIR/results.json" "$TEST_DIR/expected_results.json"
}

@test "first test fails" {
    TEST="first_fails"
    TEST_DIR="$DATA_DIR/$TEST"
    run "$RUN_SCRIPT" "$TEST" "$TEST_DIR" "$TEST_DIR"

    [[ "$status" -eq 0 ]]
    actual_matches_expected "$TEST_DIR/results.json" "$TEST_DIR/expected_results.json"
}

@test "middle test fails" {
    TEST="middle_fails"
    TEST_DIR="$DATA_DIR/$TEST"
    run "$RUN_SCRIPT" "$TEST" "$TEST_DIR" "$TEST_DIR"

    [[ "$status" -eq 0 ]]
    actual_matches_expected "$TEST_DIR/results.json" "$TEST_DIR/expected_results.json"
}

@test "last test fails" {
    TEST="last_fails"
    TEST_DIR="$DATA_DIR/$TEST"
    run "$RUN_SCRIPT" "$TEST" "$TEST_DIR" "$TEST_DIR"

    [[ "$status" -eq 0 ]]
    actual_matches_expected "$TEST_DIR/results.json" "$TEST_DIR/expected_results.json"
}

@test "missing script" {
    TEST="missing_script"
    TEST_DIR="$DATA_DIR/$TEST"
    run "$RUN_SCRIPT" "$TEST" "$TEST_DIR" "$TEST_DIR"

    [[ "$status" -eq 0 ]]
    actual_matches_expected "$TEST_DIR/results.json" "$TEST_DIR/expected_results.json"
}

@test "missing test" {
    TEST="missing_test"
    TEST_DIR="$DATA_DIR/$TEST"
    run "$RUN_SCRIPT" "$TEST" "$TEST_DIR" "$TEST_DIR"

    [[ "$status" -eq 1 ]]
}
