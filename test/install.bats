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

@test "Invoke 'install.sh -i tmp'" {
  OS=$(uname -s)
  
  run ../install.sh -i tmp
  if [[ "$OS" == "Linux" ]]; then
    [ "$status" -eq 0 ]
    elif [[ condition ]]; then
      [ "$status" -eq 127 ]
  fi
  
}