#!/usr/bin/env bash
load bats-extra

@test "say one" {
  run bash last_fails.sh one
  assert_success
  assert_output "one"
}

@test "say two" {
  run bash last_fails.sh two
  assert_success
  assert_output "two"
}

@test "say three" {
  run bash last_fails.sh three
  assert_success
  assert_output "three"
}
