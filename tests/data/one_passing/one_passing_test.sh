#!/usr/bin/env bash

@test "say hello" {
  run bash one_passing.sh
  [ "$status" -eq 0 ]
  [ "$output" == "Hello, World!" ]
}
