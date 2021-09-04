#!/usr/bin/env bash

@test "say one" {
  run bash first_fails.sh one
  [ "$status" -eq 0 ]
  [ "$output" == "one" ]
}

@test "say two" {
  run bash first_fails.sh two
  [ "$status" -eq 0 ]
  [ "$output" == "two" ]
}

@test "say three" {
  run bash first_fails.sh three
  [ "$status" -eq 0 ]
  [ "$output" == "three" ]
}
