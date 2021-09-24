#!/usr/bin/env bash
#
# leading blank lines should not be included in the test body

@test "say one" {

  run bash last_fails.sh one
  [ "$status" -eq 0 ]
  [ "$output" == "one" ]
}

@test "say two" {


  run bash last_fails.sh two
  [ "$status" -eq 0 ]
  [ "$output" == "two" ]
}

@test "say three" {



  run bash last_fails.sh three
  [ "$status" -eq 0 ]
  [ "$output" == "three" ]
}
