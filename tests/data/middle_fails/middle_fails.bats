#!/usr/bin/env bash

load bats-extra.bash

@test "say one" {
  run bash middle_fails.sh one
  [ "$status" -eq 0 ]
  [ "$output" == "one" ]
}

@test "say two" {
  run bash middle_fails.sh two
  [ "$status" -eq 0 ]
  [ "$output" == "two" ]
}

@test "say three" {
  run bash middle_fails.sh three
  [ "$status" -eq 0 ]
  [ "$output" == "three" ]
}
