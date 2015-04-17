setup() {
  
  # Create mock up test environment in TMP
  
  TMP=tmp
  
  
  # Create all the expected directories
  mkdir -p $TMP/etc/rc.d/
  mkdir -p $TMP/lib
  mkdir -p $TMP/native/usr/bin
  mkdir -p $TMP/native/usr/sbin
  mkdir -p $TMP/usr/bin
  mkdir -p $TMP/usr/sbin
  
  # Create /native symlinks for content in src/symlinks.txt
  SYMLINKS=$(cat ./src/symlinks.txt)
  for binary in $SYMLINKS; do
    ln -s /native${binary} $TMP/native${binary}
  done
  
  # Create /native symlinks for content in src/wrappers.txt
  WRAPPERS=$(cat ./src/wrappers.txt)
  for wrapper in $WRAPPERS; do
    binary=$(echo ${wrapper} | cut -f1 -d' ')
    ln -s /native${binary} $TMP/native${binary}
  done
  
  OS=$(uname -s)

  case $OS in
    Linux)
      if [[ -f /etc/redhat-release ]] ; then
        cp /etc/redhat-release $TMP/etc/redhat-release
      elif [[ -f /etc/debian_version ]] ; then
        cp /etc/debian_version $TMP/etc/debian_version
      else
        fatal "$OS is not supported."
      fi
      ;;
    *)
      fatal "$OS is not supported."
      ;;
  esac
}

teardown() {
  [ -d "$TMP" ] && rm -rf "$TMP"
}