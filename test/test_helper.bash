setup() {
  mkdir tmp
}

teardown() {
  [ -d "tmp" ] && rm -rf "tmp"
}