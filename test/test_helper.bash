IFS=$'\n\t'

setup() {
  
  # Create mock up test environment in TMP
  
  TMP=tmp
  
  
  # Create all the expected directories
  mkdir -p $TMP/bin
  mkdir -p $TMP/etc/rc.d/
  mkdir -p $TMP/lib
  mkdir -p $TMP/native/usr/bin
  mkdir -p $TMP/native/usr/sbin
  mkdir -p $TMP/usr/bin
  mkdir -p $TMP/usr/sbin
  
  # Crete required binaries for chroot
  cp /bin/* $TMP/bin
  cp /usr/bin/* $TMP/usr/bin
  cp /usr/sbin/* $TMP/usr/sbin
  
  # Remove copied symlinks and wrappers of they exist
  
  SYMLINKS=$(cat ./src/symlinks.txt)
  for binary in $SYMLINKS; do
    if [[ -e $TMP${binary} ]]; then
      rm -rf $TMP${binary}
    fi
  done
  
  WRAPPERS=$(cat ./src/wrappers.txt)
  for wrapper in $WRAPPERS; do
    binary=$(echo ${wrapper} | cut -f1 -d' ')
    if [[ -e $TMP${binary} ]]; then
      rm -rf $TMP${binary}
    fi
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