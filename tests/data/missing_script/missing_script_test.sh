#!/usr/bin/env bash
load bats-extra

@test "say hello" {
  run bash one_passing.sh
  assert_success
  assert_output "Hello, World!"
}
