#!/usr/bin/env bats

load test_helper

@test "Invoke joyent_rc.local" {
  run ./lib/smartdc/joyent_rc.local
  [ "$status" -eq 0 ]
}
