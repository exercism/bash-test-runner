#!/usr/bin/env bats

RUN_SCRIPT='./bin/run.sh'
DATA_DIR='tests/data'

@test "one passing test" {
    TEST="one_passing"
    TEST_DIR="$DATA_DIR/$TEST"
    run "$RUN_SCRIPT" "$TEST" "$TEST_DIR" "$TEST_DIR"

    RESULTS=$(cat "$TEST_DIR/results.json")
    EXPECTED_RESULTS=$(cat "$TEST_DIR/expected_results.json")

    [[ "$status" -eq 0 ]]
    [[ "$RESULTS" == "$EXPECTED_RESULTS" ]]
}

@test "three passing tests" {
    TEST="three_passing"
    TEST_DIR="$DATA_DIR/$TEST"
    run "$RUN_SCRIPT" "$TEST" "$TEST_DIR" "$TEST_DIR"

    RESULTS=$(cat "$TEST_DIR/results.json")
    EXPECTED_RESULTS=$(cat "$TEST_DIR/expected_results.json")

    [[ "$status" -eq 0 ]]
    [[ "$RESULTS" == "$EXPECTED_RESULTS" ]]
}

@test "first test fails" {
    TEST="first_fails"
    TEST_DIR="$DATA_DIR/$TEST"
    run "$RUN_SCRIPT" "$TEST" "$TEST_DIR" "$TEST_DIR"

    RESULTS=$(cat "$TEST_DIR/results.json")
    EXPECTED_RESULTS=$(cat "$TEST_DIR/expected_results.json")

    [[ "$status" -eq 0 ]]
    [[ "$RESULTS" == "$EXPECTED_RESULTS" ]]
}

@test "middle test fails" {
    TEST="middle_fails"
    TEST_DIR="$DATA_DIR/$TEST"
    run "$RUN_SCRIPT" "$TEST" "$TEST_DIR" "$TEST_DIR"

    RESULTS=$(cat "$TEST_DIR/results.json")
    EXPECTED_RESULTS=$(cat "$TEST_DIR/expected_results.json")

    [[ "$status" -eq 0 ]]
    [[ "$RESULTS" == "$EXPECTED_RESULTS" ]]
}

@test "last test fails" {
    TEST="last_fails"
    TEST_DIR="$DATA_DIR/$TEST"
    run "$RUN_SCRIPT" "$TEST" "$TEST_DIR" "$TEST_DIR"

    RESULTS=$(cat "$TEST_DIR/results.json")
    EXPECTED_RESULTS=$(cat "$TEST_DIR/expected_results.json")

    [[ "$status" -eq 0 ]]
    [[ "$RESULTS" == "$EXPECTED_RESULTS" ]]
}

@test "missing script" {
    TEST="missing_script"
    TEST_DIR="$DATA_DIR/$TEST"
    run "$RUN_SCRIPT" "$TEST" "$TEST_DIR" "$TEST_DIR"

    RESULTS=$(cat "$TEST_DIR/results.json")
    EXPECTED_RESULTS=$(cat "$TEST_DIR/expected_results.json")

    [[ "$status" -eq 0 ]]
    [[ "$RESULTS" == "$EXPECTED_RESULTS" ]]
}

@test "missing test" {
    TEST="missing_test"
    TEST_DIR="$DATA_DIR/$TEST"
    run "$RUN_SCRIPT" "$TEST" "$TEST_DIR" "$TEST_DIR"

    [[ "$status" -eq 1 ]]
}