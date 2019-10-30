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

BATS="$PWD/bats/bin/bats"

to_json_value() {
    local input
    local result

    IFS= input="$(< /dev/stdin)"

    if [[ -z $input ]]; then
        printf "null"
        return
    fi

    result="${input//\\/\\\\}"

    result="${result//$'\b'/\\b}"
    result="${result//$'\f'/\\f}"
    result="${result//$'\n'/\\n}"
    result="${result//$'\r'/\\r}"
    result="${result//$'\t'/\\t}"

    result="${result//\"/\\\"}"

    printf '"%s"' "$result"
}


run_tests() {
    local slug="$1"
    local solution_dir="$2"
    local output_file="$3"

    echo "Running tests."

    cd "$solution_dir"

    echo "Test output:"

    "$BATS" --tap "${slug//-/_}_test.sh" 2>&1 | tee "$output_file" || true

    echo "Test run ended. Output saved in $output_file"

    cd ~-
}

build_report() {
    local output_file="$1"
    local json_result_file="$2"

    echo "Producing JSON report."

    readarray -t output < "$output_file"

    if [[ ${output[0]} =~ ^([0-9]+)\.\.([0-9]+)$ ]]; then
        local first_test="${BASH_REMATCH[1]}"
        local last_test="${BASH_REMATCH[2]}"
        local test_count=$(( last_test - first_test + 1 ))
    else
        error "$output_file" "$json_result_file"; return
    fi

    echo "Tried to run $test_count tests according to TAP plan."

    local results
    local status="pass"

    for (( i = 1; i < ${#output[@]}; i++ )); do
        if [[ ${output[$i]} =~ ^(not )?ok\ [0-9]+\ (.*)$ ]]; then
            local failed="${BASH_REMATCH[1]}"
            local test_name="${BASH_REMATCH[2]}"
        else
            error "$output_file" "$json_result_file"; return
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

    if [[ $status == fail ]]; then
        return 1
    else
        return 0
    fi
}

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

error() {
    local output_file="$1"
    local json_result_file="$2"

    echo "Failed to parse output."
    echo "This probably means there was an error running the tests."

    printf '{ "status": "error", "message": %s }\n' \
        "$(to_json_value < "$output_file")" \
        > "$json_result_file"

    echo "Wrote error report to $json_result_file"
}

print_report() {
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
    local test_name="$1"
    local message="$2"

    printf '{ "name": %s, "status": "fail", "message": %s}\n' \
        "$(to_json_value <<< "$test_name")" \
        "$(to_json_value <<< "$message")"
}

print_passed_test() {
    local test_name="$1"

    printf '{ "name": %s, "status": "pass" }\n' \
        "$(to_json_value <<< "$test_name")"
}

main "$@"
