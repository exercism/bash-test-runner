#!/usr/bin/env bash
load bats-extra

@test "say one" {
  run bash middle_fails.sh one
  assert_output "one"
  assert_success
}

@test "say two" {
  run bash middle_fails.sh two
  assert_output "two"
  assert_success
}

@test "say three" {
  run bash middle_fails.sh three
  assert_output "three"
  assert_success
}
