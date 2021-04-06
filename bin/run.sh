#!/bin/bash

set -o errexit
set -o nounset

# Arguments:
# $1: exercise slug
# $2: path to solution directory
# $3: path to output directory
#
# Example:
# ./run.sh two-fer path/to/two-fer path/to/output/directory
# ./run.sh two-fer twofer output
#
# First runs the tests with bats and saves the TAP output,
# then parses that TAP file to produce the JSON file.

main() {
    echo "Running exercise tests for Bash"

    local slug="$1"
    echo "Test slug: ${slug}"

    local solution_dir
    solution_dir="$(realpath "$2")"
    echo "Solution directory: ${solution_dir}"

    local output_dir
    output_dir="$(realpath "$3")"
    echo "Output directory: ${output_dir}"

    local output_file="$output_dir/results.out"
    local json_result_file="$output_dir/results.json"

    run_tests "$slug" "$solution_dir" "$output_file"
    build_report "$output_file" "$json_result_file"
}

to_json_value() {
    # Turn strings into JSON values.
    #
    # Empty string will become "null", any other value will be encoded as a
    # string.

    local input="$1"

    if [[ -z $input ]]; then
        printf "null"
        return
    fi

    local result="${input//\\/\\\\}"

    result="${result//$'\b'/\\b}"
    result="${result//$'\f'/\\f}"
    result="${result//$'\n'/\\n}"
    result="${result//$'\r'/\\r}"
    result="${result//$'\t'/\\t}"

    result="${result//\"/\\\"}"

    printf '"%s"' "$result"
}

run_tests() {
    # Run tests and pipe output to results.out file.

    local slug="$1"
    local solution_dir="$2"
    local output_file="$3"

    echo "Running tests."

    cd "$solution_dir"

    echo "Test output:"

    bats --tap "${slug//-/_}_test.sh" 2>&1 | tee "$output_file" || true

    echo "Test run ended. Output saved in $output_file"

    cd ~-
}

build_report() {
    # Parse results.out and write result to results.json

    local output_file="$1"
    local json_result_file="$2"

    echo "Producing JSON report."

    readarray -t output < "$output_file"

    if [[ ${output[0]} =~ ^([0-9]+)\.\.([0-9]+)$ ]]; then
        local first_test="${BASH_REMATCH[1]}"
        local last_test="${BASH_REMATCH[2]}"
        local test_count=$(( last_test - first_test + 1 ))
    else
        error "$output_file" "$json_result_file"; return 1
    fi

    echo "Tried to run $test_count tests according to TAP plan."

    local results
    local status="pass"

    for (( i = 1; i < ${#output[@]}; i++ )); do
        if [[ ${output[$i]} =~ ^(not )?ok\ [0-9]+\ (.*)$ ]]; then
            local failed="${BASH_REMATCH[1]}"
            local test_name="${BASH_REMATCH[2]}"
        else
            error "$output_file" "$json_result_file"; return 1
        fi

        if [[ -z $failed ]]; then
            results+=("$(print_passed_test "$test_name")")
        else
            status="fail"

            local error_message=""

            for (( j = i + 1; j < ${#output[@]}; j++ )); do
                if [[ ${output[$j]} =~ ^#\ (.*)$ ]]; then
                    error_message+="${BASH_REMATCH[1]}"$'\n'
                else
                    break
                fi
            done

            results+=("$(print_failed_test "$test_name" "$error_message")")

            (( i = j - 1 ))
        fi
    done

    print_report "$status" "${results[@]}" > "$json_result_file"

    echo "Wrote report to $json_result_file"

    return 0
}

error() {
    # Store entire output to results.json file, in case of an error.

    local output_file="$1"
    local json_result_file="$2"

    echo "Failed to parse output."
    echo "This probably means there was an error running the tests."

    printf '{ "status": "error", "message": %s }\n' \
        "$(to_json_value "$(< "$output_file")")" \
        > "$json_result_file"

    echo "Wrote error report to $json_result_file"
}

print_report() {
    # Print complete result JSON, given the overall status and a list of
    # already JSON-encoded test results.

    local status="$1"
    shift

    local test_results=("$@")

    local result
    result="$(printf '{ "status": "%s", "tests": [' "$status")"
    IFS=, result+="${test_results[*]}"
    result+="]}"

    printf "%s" "$result"
}

print_failed_test() {
    # Print result of failed test as JSON.

    local test_name="$1"
    local message="$2"

    printf '{ "name": %s, "status": "fail", "message": %s}\n' \
        "$(to_json_value "$test_name")" \
        "$(to_json_value "$message")"
}

print_passed_test() {
    # Print result of passed test as JSON.

    local test_name="$1"

    printf '{ "name": %s, "status": "pass" }\n' \
        "$(to_json_value "$test_name")"
}

main "$@"
