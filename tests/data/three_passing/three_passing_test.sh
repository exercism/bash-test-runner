#!/usr/bin/env bash
load bats-extra

@test "say one" {
  run bash three_passing.sh one
  assert_success
  assert_output "one"
}

@test "say two" {
  run bash three_passing.sh two
  assert_success
  assert_output "two"
}

@test "say three" {
  run bash three_passing.sh three
  assert_success
  assert_output "three"
}
