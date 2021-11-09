#!/usr/bin/env bash
#
# "skip" lines should not be included in the test body

load bats-extra

@test "say one" {
  #[[ $BATS_RUN_SKIPPED == "true" ]] || skip
  run bash middle_fails.sh one
  [ "$status" -eq 0 ]
  [ "$output" == "one" ]
}

@test "say two" {
  [[ $BATS_RUN_SKIPPED == "true" ]] || skip
  run bash middle_fails.sh two
  [ "$status" -eq 0 ]
  [ "$output" == "two" ]
}

@test "say three" {
  [[ $BATS_RUN_SKIPPED == "true" ]] || skip
  run bash middle_fails.sh three
  [ "$status" -eq 0 ]
  [ "$output" == "three" ]
}
