#!/usr/bin/env bats

RUN_SCRIPT='./run.sh'
DATA_DIR='tests/data'

setup() {
    output_dir="$(mktemp -d bash-test-runner-test.XXXXXXXX)"
}

teardown() {
    rm -r "$output_dir"
}

@test "one passing test" {
    run "$RUN_SCRIPT" one-passing "$DATA_DIR"/one_passing "$output_dir"

    [[ "$status" -eq 0 ]]

    actual_tap_output="$(< "$output_dir/results.out")"
    expected_tap_output="\
1..1
ok 1 say hello\
"
    [[ "$actual_tap_output" == "$expected_tap_output" ]]

    [[ "$(jq -r .status < "$output_dir/results.json")" == pass ]]
    [[ "$(jq .message < "$output_dir/results.json")" == null ]]
    [[ "$(jq '.tests | length' < "$output_dir/results.json")" == 1 ]]
    [[ "$(jq -r '.tests[0].name' < "$output_dir/results.json")" \
        == "say hello" ]]
    [[ "$(jq -r '.tests[0].status' < "$output_dir/results.json")" == pass ]]
    [[ "$(jq '.tests[0].message' < "$output_dir/results.json")" == null ]]
}

@test "three passing tests" {
    run "$RUN_SCRIPT" \
        three-passing \
        "$DATA_DIR"/three_passing \
        "$output_dir"

    [[ "$status" -eq 0 ]]

    actual_tap_output="$(< "$output_dir/results.out")"
    expected_tap_output="\
1..3
ok 1 say one
ok 2 say two
ok 3 say three\
"

    [[ "$actual_tap_output" == "$expected_tap_output" ]]

    [[ "$(jq -r .status < "$output_dir/results.json")" == pass ]]
    [[ "$(jq .message < "$output_dir/results.json")" == null ]]
    [[ "$(jq '.tests | length' < "$output_dir/results.json")" == 3 ]]

    [[ "$(jq -r '.tests[0].name' < "$output_dir/results.json")" \
        == "say one" ]]
    [[ "$(jq -r '.tests[0].status' < "$output_dir/results.json")" == pass ]]
    [[ "$(jq '.tests[0].message' < "$output_dir/results.json")" == null ]]

    [[ "$(jq -r '.tests[1].name' < "$output_dir/results.json")" \
        == "say two" ]]
    [[ "$(jq -r '.tests[1].status' < "$output_dir/results.json")" == pass ]]
    [[ "$(jq '.tests[1].message' < "$output_dir/results.json")" == null ]]

    [[ "$(jq -r '.tests[2].name' < "$output_dir/results.json")" \
        == "say three" ]]
    [[ "$(jq -r '.tests[2].status' < "$output_dir/results.json")" == pass ]]
    [[ "$(jq '.tests[2].message' < "$output_dir/results.json")" == null ]]
}

@test "first test fails" {
    run "$RUN_SCRIPT" \
        first-fails \
        "$DATA_DIR"/first_fails \
        "$output_dir"

    [[ "$status" -eq 1 ]]

    actual_tap_output="$(< "$output_dir/results.out")"
    expected_tap_output="\
1..3
not ok 1 say one
# (in test file first_fails_test.sh, line 6)
#   \`[ \"\$output\" == \"one\" ]' failed
ok 2 say two
ok 3 say three\
"

    [[ "$actual_tap_output" == "$expected_tap_output" ]]

    [[ "$(jq -r .status < "$output_dir/results.json")" == fail ]]
    [[ "$(jq .message < "$output_dir/results.json")" == null ]]
    [[ "$(jq '.tests | length' < "$output_dir/results.json")" == 3 ]]

    [[ "$(jq -r '.tests[0].name' < "$output_dir/results.json")" \
        == "say one" ]]
    [[ "$(jq -r '.tests[0].status' < "$output_dir/results.json")" == fail ]]

    [[ "$(jq -r '.tests[0].message' < "$output_dir/results.json")" \
        == "\
(in test file first_fails_test.sh, line 6)
  \`[ \"\$output\" == \"one\" ]' failed" ]]

    [[ "$(jq -r '.tests[1].name' < "$output_dir/results.json")" \
        == "say two" ]]
    [[ "$(jq -r '.tests[1].status' < "$output_dir/results.json")" == pass ]]
    [[ "$(jq '.tests[1].message' < "$output_dir/results.json")" == null ]]

    [[ "$(jq -r '.tests[2].name' < "$output_dir/results.json")" \
        == "say three" ]]
    [[ "$(jq -r '.tests[2].status' < "$output_dir/results.json")" == pass ]]
    [[ "$(jq '.tests[2].message' < "$output_dir/results.json")" == null ]]
}

@test "middle test fails" {
    run "$RUN_SCRIPT" \
        middle-fails \
        "$DATA_DIR"/middle_fails \
        "$output_dir"

    [[ "$status" -eq 1 ]]

    actual_tap_output="$(< "$output_dir/results.out")"
    expected_tap_output="\
1..3
ok 1 say one
not ok 2 say two
# (in test file middle_fails_test.sh, line 12)
#   \`[ \"\$output\" == \"two\" ]' failed
ok 3 say three\
"

    [[ "$actual_tap_output" == "$expected_tap_output" ]]

    [[ "$(jq -r .status < "$output_dir/results.json")" == fail ]]
    [[ "$(jq .message < "$output_dir/results.json")" == null ]]
    [[ "$(jq '.tests | length' < "$output_dir/results.json")" == 3 ]]

    [[ "$(jq -r '.tests[0].name' < "$output_dir/results.json")" \
        == "say one" ]]
    [[ "$(jq -r '.tests[0].status' < "$output_dir/results.json")" == pass ]]
    [[ "$(jq '.tests[0].message' < "$output_dir/results.json")" == null ]]

    [[ "$(jq -r '.tests[1].name' < "$output_dir/results.json")" \
        == "say two" ]]
    [[ "$(jq -r '.tests[1].status' < "$output_dir/results.json")" == fail ]]

    [[ "$(jq -r '.tests[1].message' < "$output_dir/results.json")" \
        == "\
(in test file middle_fails_test.sh, line 12)
  \`[ \"\$output\" == \"two\" ]' failed" ]]

    [[ "$(jq -r '.tests[2].name' < "$output_dir/results.json")" \
        == "say three" ]]
    [[ "$(jq -r '.tests[2].status' < "$output_dir/results.json")" == pass ]]
    [[ "$(jq '.tests[2].message' < "$output_dir/results.json")" == null ]]
}

@test "last test fails" {
    run "$RUN_SCRIPT" \
        last-fails \
        "$DATA_DIR"/last_fails \
        "$output_dir"

    [[ "$status" -eq 1 ]]

    actual_tap_output="$(< "$output_dir/results.out")"
    expected_tap_output="\
1..3
ok 1 say one
ok 2 say two
not ok 3 say three
# (in test file last_fails_test.sh, line 18)
#   \`[ \"\$output\" == \"three\" ]' failed\
"

    [[ "$actual_tap_output" == "$expected_tap_output" ]]

    [[ "$(jq -r .status < "$output_dir/results.json")" == fail ]]
    [[ "$(jq .message < "$output_dir/results.json")" == null ]]
    [[ "$(jq '.tests | length' < "$output_dir/results.json")" == 3 ]]

    [[ "$(jq -r '.tests[0].name' < "$output_dir/results.json")" \
        == "say one" ]]
    [[ "$(jq -r '.tests[0].status' < "$output_dir/results.json")" == pass ]]
    [[ "$(jq '.tests[0].message' < "$output_dir/results.json")" == null ]]

    [[ "$(jq -r '.tests[1].name' < "$output_dir/results.json")" \
        == "say two" ]]
    [[ "$(jq -r '.tests[1].status' < "$output_dir/results.json")" == pass ]]
    [[ "$(jq '.tests[1].message' < "$output_dir/results.json")" == null ]]

    [[ "$(jq -r '.tests[2].name' < "$output_dir/results.json")" \
        == "say three" ]]
    [[ "$(jq -r '.tests[2].status' < "$output_dir/results.json")" == fail ]]

    [[ "$(jq -r '.tests[2].message' < "$output_dir/results.json")" \
        == "\
(in test file last_fails_test.sh, line 18)
  \`[ \"\$output\" == \"three\" ]' failed" ]]
}

@test "missing script" {
    run "$RUN_SCRIPT" missing-script "$DATA_DIR"/missing_script "$output_dir"

    [[ "$status" -eq 1 ]]

    [[ "$(jq -r .status < "$output_dir/results.json")" == fail ]]
    [[ "$(jq .message < "$output_dir/results.json")" == null ]]
    [[ "$(jq '.tests | length' < "$output_dir/results.json")" == 1 ]]

    [[ "$(jq -r '.tests[0].name' < "$output_dir/results.json")" \
        == "say hello" ]]
    [[ "$(jq -r '.tests[0].status' < "$output_dir/results.json")" == fail ]]
    [[ "$(jq '.tests[0].message' < "$output_dir/results.json")" \
        =~ \$status.*-eq.*0.*failed\ with\ status\ 127 ]]
}

@test "missing test" {
    run "$RUN_SCRIPT" missing-test "$DATA_DIR"/missing_test "$output_dir"

    [[ "$status" -eq 1 ]]

    [[ "$(jq -r '.status' < "$output_dir/results.json")" == error ]]

    [[ "$(jq -r '.message' < "$output_dir/results.json")" =~ \
bats:\ .*${PWD}/${DATA_DIR}/missing_test/missing_test_test.sh\ does\ not\ exist\
    ]]

    [[ "$(jq '.tests | length' < "$output_dir/results.json")" == 0 ]]
}
