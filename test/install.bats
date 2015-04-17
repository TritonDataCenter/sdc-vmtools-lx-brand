#!/usr/bin/env bats

load test_helper

@test "Invoke install.sh without arguments prints usage" {
  run ../install.sh
  [ "$status" -eq 127 ]
}

@test "Invoke install.sh with -h argument" {
  run ../install.sh -h
  [ "$status" -eq 127 ]
}
