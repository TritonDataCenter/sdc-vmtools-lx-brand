IFS=$'\n\t'

setup() {
  
  # Create mock up test environment in TMP
  
  TMP=tmp
  
  # Create all the expected directories
  mkdir -p $TMP/etc/
  
  OS=$(uname -s)

  case $OS in
    Linux)
      if [[ -f /etc/redhat-release ]] ; then
        cp /etc/redhat-release $TMP/etc/redhat-release
      elif [[ -f /etc/debian_version ]] ; then
        cp /etc/debian_version $TMP/etc/debian_version
      else
        echo "$OS is not supported."
      fi
      ;;
    *)
      echo "$OS is not supported."
      ;;
  esac
}

teardown() {
  [ -d "$TMP" ] && rm -rf "$TMP"
}