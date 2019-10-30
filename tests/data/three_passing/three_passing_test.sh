#!/usr/bin/env bash

@test "say one" {
  run bash three_passing.sh one
  [ "$status" -eq 0 ]
  [ "$output" == "one" ]
}

@test "say two" {
  run bash three_passing.sh two
  [ "$status" -eq 0 ]
  [ "$output" == "two" ]
}

@test "say three" {
  run bash three_passing.sh three
  [ "$status" -eq 0 ]
  [ "$output" == "three" ]
}
