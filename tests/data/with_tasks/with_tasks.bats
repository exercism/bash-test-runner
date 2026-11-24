#!/usr/bin/env bats

# bats test_tags=task:1
say_one() { # @test
  [[ $BATS_RUN_SKIPPED == "true" ]] || skip
  run bash with_tasks.sh one
  [ "$status" -eq 0 ]
  [ "$output" == "one" ]
}

# bats test_tags=task:1
say_two() { # @test
  [[ $BATS_RUN_SKIPPED == "true" ]] || skip
  run bash with_tasks.sh two
  [ "$status" -eq 0 ]
  [ "$output" == "two" ]
}

# bats test_tags=task:2
say_three() { # @test
  [[ $BATS_RUN_SKIPPED == "true" ]] || skip
  run bash with_tasks.sh three
  [ "$status" -eq 0 ]
  [ "$output" == "three" ]
}

# no tags
say_four() { # @test
  run bash with_tasks.sh two
  [ "$output" == "two" ]
}
