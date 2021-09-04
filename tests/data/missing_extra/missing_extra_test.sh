#!/usr/bin/env bash
load bats-extra

@test "say one" {
  run bash missing_extra.sh one
  assert_success
  assert_output "one"
}

@test "say two" {
  run bash missing_extra.sh two
  assert_success
  assert_output "two"
}

@test "say three" {
  run bash missing_extra.sh three
  assert_success
  assert_output "three"
}
