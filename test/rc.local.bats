#!/usr/bin/env bats

load test_helper

@test "Invoke bash -n joyent_rc.local" {
  run bash -n src/lib/smartdc/joyent_rc.local
  [ "$status" -eq 0 ]
}
