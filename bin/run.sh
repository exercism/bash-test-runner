#!/usr/bin/env bash
# shellcheck disable=SC2164,SC2103

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

# the version of the test-runner interface:
# https://github.com/exercism/docs/blob/main/building/tooling/test-runners/interface.md
INTERFACE_VERSION=3

main() {
    if (($# < 3)) || [[ $1 == '-h' ]]; then
        echo "usage: $0 <exercise_slug> <solution_directory> <output_directory>"
        echo ""
        echo "Typically, solution_directory == output_directory"
        echo "example:"
        echo "\$ $0 one_passing ./tests/data/one_passing{,}"
        exit
    fi

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

    local -A test_bodies    # populated in get_test_bodies
    local -A task_ids       # populated in get_test_bodies

    run_tests "$slug" "$solution_dir" "$output_file"
    build_report "$output_file" "$json_result_file"
}

run_tests() {
    # Run tests and pipe output to results.out file.

    local slug="$1"
    local solution_dir="$2"
    local output_file="$3"

    echo "Running tests."

    cd "$solution_dir"

    local test_file
    if [[ -f .meta/config.json ]]; then
        test_file=$(jq -r '.files.test[0]' .meta/config.json)
    else
        test_file="${slug//-/_}.bats"
        # test scripts may be (old) xxxx_test.sh
        [[ -f "$test_file" ]] || test_file="${slug//-/_}_test.sh"
    fi

    if [[ -e "$test_file" ]]; then
        contents=$( < "$test_file" )
        sed 's/(load bats-extra)\.bash/$1/' > "$test_file" <<< "$contents"
    fi

    echo "Test output:"

    bats --tap "$test_file" 2>&1 | tee "$output_file" || true

    get_test_bodies "$test_file"

    echo "Test run ended. Output saved in $output_file"

    cd -
}

get_test_bodies() {
    local test_file=$1
    local name line indent task_id
    local state="out"
    local body=()
    test_bodies=()
    task_ids=()

    local start_test_re='^@test ['\''"](.+)['\''"] \{[[:blank:]]*$'
    # function-style tests: `test_name() { # @test`
    local start_func_re='^([A-Za-z_][A-Za-z0-9_]*)[[:blank:]]*\(\)[[:blank:]]*\{[[:blank:]]*#[[:blank:]]*@test[[:blank:]]*$'
    # tag comment: `# bats test_tags=task:1,other`
    local tags_re='^[[:blank:]]*#[[:blank:]]*bats[[:blank:]]+test_tags[[:blank:]]*=(.*)$'
    local task_re='(^|[[:blank:],])task:([0-9]+)([[:blank:],]|$)'
    local end_test_re='^\}[[:blank:]]*$'

    while IFS= read -r line; do
        case "$state" in
            out)
                if [[ $line =~ $tags_re ]]; then
                    if [[ ${BASH_REMATCH[1]} =~ $task_re ]]; then
                        task_id=${BASH_REMATCH[2]}
                    fi
                elif [[ $line =~ $start_test_re || $line =~ $start_func_re ]]; then
                    name=${BASH_REMATCH[1]}
                    body=()
                    state="in"
                fi
                ;;
            in)
                if [[ $line =~ $end_test_re ]]; then
                    test_bodies["$name"]=$(printf '%s\n' "${body[@]}")
                    if [[ -n ${task_id:-} ]]; then
                        task_ids["$name"]=$task_id
                    fi
                    unset task_id
                    state="out"
                elif [[ $line == *BATS_RUN_SKIPPED*skip* ]]; then
                    # skip the skips
                    continue
                elif ((${#body[@]} == 0)) && [[ $line == *([[:blank:]]) ]]; then
                    # ignore blank lines at the top of the test body
                    continue
                else
                    # We want to unindent the body: find the indentation of the first line.
                    ((${#body[@]} == 0)) && indent=${line%%[^[:blank:]]*}

                    body+=("${line#"$indent"}")
                fi
                ;;
        esac
    done < "$test_file"
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
        local test_count=$((last_test - first_test + 1))
    else
        error "$output_file" "$json_result_file"
        return 1
    fi

    echo "Tried to run $test_count tests according to TAP plan."

    # `results` is a flat array that holds 5 elements for each test, in order:
    #   1. the test name
    #   2. the status, "pass" or "fail"
    #   3. the test code (the body of the test)
    #   4. the error message (empty if the test passed)
    #   5. the task id (empty if the test has no "task:" tag)
    # So test 1 is results[0..4], test 2 is results[5..9], and so on.
    # print_report turns each chunk of 5 into one test object.
    local results=()
    local status="pass"
    local test_body task_id

    for ((i = 1; i < ${#output[@]}; i++)); do
        # skip stray diagnostics, such as "# tags: task:1" after a passing test
        [[ ${output[$i]} == "#"* ]] && continue

        if [[ ${output[$i]} =~ ^(not )?ok\ [0-9]+\ (.*)$ ]]; then
            local failed="${BASH_REMATCH[1]}"
            local test_name="${BASH_REMATCH[2]}"
        else
            error "$output_file" "$json_result_file"
            return 1
        fi

        test_body=${test_bodies[$test_name]:-}
        task_id=${task_ids[$test_name]:-}

        if [[ -z $failed ]]; then
            results+=("$test_name" "pass" "$test_body" "" "$task_id")
        else
            status="fail"

            local error_message=""

            for ((j = i + 1; j < ${#output[@]}; j++)); do
                if [[ ${output[$j]} =~ ^#\ ?(.*)$ ]]; then
                    # bats reports tags as a diagnostic: not part of the error
                    [[ ${BASH_REMATCH[1]} == "tags:"* ]] ||
                        error_message+="${BASH_REMATCH[1]}"$'\n'
                else
                    break
                fi
            done

            results+=("$test_name" "fail" "$test_body" "$error_message" "$task_id")

            ((i = j - 1))
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

    jq  --null-input \
        --argjson version "$INTERFACE_VERSION" \
        --arg status "error" \
        --arg message "$(< "$output_file")" \
        '{version: $version, status: $status, message: $message}' \
    > "$json_result_file"

    echo "Wrote error report to $json_result_file"
}

print_report() {
    # Print the complete result JSON, given the overall status and the
    # `results` array from build_report (5 elements per test).
    #
    # The elements reach jq through `--args`, so jq sees them as the array
    # $ARGS.positional, called $fields below. `range(0; $fields | length; 5)`
    # gives the index of the first element of each test (0, 5, 10, ...). For
    # each index $i, jq takes the slice $fields[$i:$i + 5] and names its
    # elements $name, $test_status, $code, $message and $task_id. From those
    # it builds one test object:
    #   name, status and test_code always
    #   message, added only if the test failed
    #   task_id, added as a number only if it is not empty
    # The `[ ... ]` around this collects the objects into the "tests" array.
    #
    # One jq process builds the whole report. Starting a jq process for each
    # test cost about 10 ms per test.
    local status=$1
    shift
    jq  --null-input \
        --argjson version "$INTERFACE_VERSION" \
        --arg status "$status" \
        --arg bash "$BASH_VERSION" \
        --arg bats "$(bats --version)" \
        '{
            version: $version,
            status: $status,
            "test-environment": {bash: $bash, bats: $bats},
            tests: [
                $ARGS.positional as $fields
                | range(0; $fields | length; 5) as $i
                | $fields[$i:$i + 5] as [$name, $test_status, $code, $message, $task_id]
                | {name: $name, status: $test_status, test_code: $code}
                + (if $test_status == "fail" then {message: $message} else {} end)
                + (if $task_id == "" then {} else {task_id: ($task_id | tonumber)} end)
            ]
        }' \
        --args "$@"
}

main "$@"
